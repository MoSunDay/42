#!/usr/bin/env python3
"""
Pixellab API v2 client for batch UI asset generation.
Handles async job submission, polling, and download.
"""

import os
import time
import json
import base64
import requests
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional

API_KEY = os.environ["PIXELLAB_API_KEY"]
BASE_URL = "https://api.pixellab.ai/v2"
HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json",
}
OUTPUT_BASE = Path(__file__).parent.parent / "assets" / "images" / "ui"

MAX_CONCURRENT = 3
POLL_INTERVAL = 8
POLL_TIMEOUT = 300


@dataclass
class AssetJob:
    category: str
    filename: str
    prompt: str
    width: int
    height: int
    no_background: bool = True
    color_palette: Optional[str] = None
    job_id: Optional[str] = None
    status: str = "pending"
    error: Optional[str] = None

    @property
    def output_path(self) -> Path:
        return OUTPUT_BASE / self.category / f"{self.filename}.png"

    @property
    def key(self) -> str:
        return f"{self.category}/{self.filename}"


def submit_ui_job(job: AssetJob) -> bool:
    data = {
        "description": job.prompt,
        "image_size": {"width": job.width, "height": job.height},
        "no_background": job.no_background,
    }
    if job.color_palette:
        data["color_palette"] = job.color_palette

    try:
        r = requests.post(
            f"{BASE_URL}/generate-ui-v2", headers=HEADERS, json=data, timeout=30
        )
        if r.status_code == 202:
            result = r.json()
            job_id = (
                result.get("background_job_id")
                or result.get("data", {}).get("job_id")
                or result.get("job_id")
                or result.get("data", {}).get("id")
            )
            if job_id:
                job.job_id = job_id
                job.status = "processing"
                return True
            else:
                job.status = "failed"
                job.error = f"No job_id in response: {json.dumps(result)[:200]}"
                return False
        elif r.status_code == 200:
            result = r.json()
            img_data = _extract_image(result)
            if img_data:
                _save_image(img_data, job.output_path)
                job.status = "completed"
                return True
            else:
                job.status = "failed"
                job.error = "No image in sync response"
                return False
        else:
            job.status = "failed"
            job.error = f"HTTP {r.status_code}: {r.text[:200]}"
            return False
    except Exception as e:
        job.status = "failed"
        job.error = str(e)
        return False


def submit_pixflux_job(job: AssetJob) -> bool:
    data = {
        "description": job.prompt,
        "image_size": {"width": job.width, "height": job.height},
        "no_background": job.no_background,
        "text_guidance_scale": 8,
    }

    try:
        r = requests.post(
            f"{BASE_URL}/create-image-pixflux", headers=HEADERS, json=data, timeout=60
        )
        if r.status_code == 200:
            result = r.json()
            img_data = _extract_image(result)
            if img_data:
                _save_image(img_data, job.output_path)
                job.status = "completed"
                return True
            else:
                job.status = "failed"
                job.error = "No image in pixflux response"
                return False
        else:
            job.status = "failed"
            job.error = f"HTTP {r.status_code}: {r.text[:200]}"
            return False
    except Exception as e:
        job.status = "failed"
        job.error = str(e)
        return False


def poll_job(job: AssetJob) -> bool:
    if not job.job_id:
        return False

    start = time.time()
    while time.time() - start < POLL_TIMEOUT:
        try:
            r = requests.get(
                f"{BASE_URL}/background-jobs/{job.job_id}",
                headers=HEADERS,
                timeout=15,
            )
            if r.status_code == 200:
                result = r.json()
                data = result.get("data", result)
                status = data.get("status", "unknown")

                if status in ("completed", "done", "success"):
                    img_data = _extract_bg_image(data)
                    if not img_data:
                        img_data = _extract_image(data)
                    if img_data:
                        _save_image(img_data, job.output_path)
                        job.status = "completed"
                        return True
                    else:
                        job.status = "failed"
                        job.error = (
                            f"Completed but no image data. Keys: {list(data.keys())}"
                        )
                        return False
                elif status in ("failed", "error"):
                    job.status = "failed"
                    job.error = data.get("error", "Unknown error")
                    return False
        except Exception as e:
            pass

        time.sleep(POLL_INTERVAL)

    job.status = "failed"
    job.error = "Poll timeout"
    return False


def _extract_image(data: dict) -> Optional[bytes]:
    for key in ("image", "image_base64", "result"):
        val = data.get(key)
        if val:
            return _decode_image_val(val)

    images = data.get("images", [])
    if images:
        return _decode_image_val(images[0])

    url = data.get("image_url") or data.get("download_url") or data.get("url")
    if url:
        return _download_url(url)

    return None


def _extract_bg_image(data: dict) -> Optional[bytes]:
    lr = data.get("last_response")
    if not lr:
        return None
    images = lr.get("images", [])
    if images:
        return _decode_image_val(images[0])
    return None


def _decode_image_val(val) -> Optional[bytes]:
    if isinstance(val, bytes):
        return val
    if isinstance(val, dict):
        b64 = val.get("base64")
        if b64:
            return base64.b64decode(b64)
        url = val.get("url") or val.get("download_url")
        if url:
            return _download_url(url)
        return None
    if isinstance(val, str):
        if val.startswith("data:image"):
            val = val.split(",", 1)[1]
        try:
            return base64.b64decode(val)
        except Exception:
            return _download_url(val)
    return None


def _download_url(url: str) -> Optional[bytes]:
    try:
        r = requests.get(url, timeout=30)
        if r.status_code == 200:
            return r.content
    except Exception:
        pass
    return None


def _save_image(data: bytes, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "wb") as f:
        f.write(data)


def batch_generate(
    jobs: list[AssetJob], use_pixflux: bool = False, replace: bool = False
):
    print(
        f"\nBatch: {len(jobs)} assets ({'pixflux' if use_pixflux else 'generate-ui-v2'})"
    )
    print("=" * 60)

    if replace:
        for j in jobs:
            backup = j.output_path.with_suffix(".png.bak")
            if j.output_path.exists() and not backup.exists():
                j.output_path.rename(backup)
        pending = list(jobs)
    else:
        pending = [j for j in jobs if not j.output_path.exists()]
        if not pending:
            print("All assets already exist, skipping.")
            return

    print(f"Need to generate: {len(pending)} ({len(jobs) - len(pending)} exist)")

    processing: list[AssetJob] = []
    completed = 0
    failed = 0
    idx = 0

    while idx < len(pending) or processing:
        while len(processing) < MAX_CONCURRENT and idx < len(pending):
            job = pending[idx]
            idx += 1

            submit_fn = submit_pixflux_job if use_pixflux else submit_ui_job
            ok = submit_fn(job)
            print(
                f"  [{idx}/{len(pending)}] {job.key}: {'submitted' if ok else 'submit failed'}"
            )

            if ok:
                if job.status == "completed":
                    completed += 1
                    print(f"    -> completed (sync)")
                else:
                    processing.append(job)
            else:
                failed += 1
                print(f"    -> ERROR: {job.error}")

            time.sleep(1)

        if not processing:
            break

        done = []
        for job in processing:
            if job.status == "processing":
                poll_job(job)
            if job.status in ("completed", "failed"):
                done.append(job)
                if job.status == "completed":
                    completed += 1
                    print(f"  DONE: {job.key}")
                else:
                    failed += 1
                    print(f"  FAIL: {job.key} - {job.error}")

        processing = [j for j in processing if j.status == "processing"]
        if processing:
            time.sleep(POLL_INTERVAL)

    print(
        f"\nResult: {completed} completed, {failed} failed, {len(pending) - completed - failed} timed out"
    )
