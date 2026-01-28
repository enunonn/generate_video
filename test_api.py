#!/usr/bin/env python3
"""
Generate Video RunPod API 테스트 스크립트
generate_video_client를 사용해서 이미지→비디오 워크플로우를 한 번에 테스트합니다.
"""

import os
import sys
import argparse
from pathlib import Path
import json

from generate_video_client import GenerateVideoClient


def _load_test_env():
    """프로젝트 루트의 test.env를 읽어서 환경변수로 주입 (있을 때만)."""
    env_path = Path(__file__).resolve().parent.parent / "test.env"
    if not env_path.exists():
        return
    with env_path.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            k, v = k.strip(), v.strip()
            if v.startswith('"') and v.endswith('"'):
                v = v[1:-1]
            os.environ.setdefault(k, v)


_load_test_env()


def get_config():
    """test.env 또는 환경변수에서 API 설정 읽기."""
    api_key = os.getenv("runpod_API_KEY") or os.getenv("RUNPOD_API_KEY")
    endpoint_id = (
        os.getenv("generate_video")
        or os.getenv("GENERATE_VIDEO_ENDPOINT_ID")
        or os.getenv("RUNPOD_ENDPOINT_ID")
    )
    if not api_key or not endpoint_id:
        print("필요한 환경변수:")
        print("  runpod_API_KEY (또는 RUNPOD_API_KEY)")
        print("  generate_video (또는 GENERATE_VIDEO_ENDPOINT_ID / RUNPOD_ENDPOINT_ID)")
        print("프로젝트 루트의 test.env 또는 .env에 설정해 주세요.")
        return None, None
    return api_key.strip(), endpoint_id.strip()


def main():
    parser = argparse.ArgumentParser(description="Generate Video API 테스트 (Wan2.2)")

    examples_dir = Path(__file__).resolve().parent / "examples"
    default_input = examples_dir / "input" / "test_input.png"
    default_output = examples_dir / "output" / "out_test.mp4"

    parser.add_argument(
        "--image-file",
        default=str(default_input),
        help="입력 이미지 경로 (기본: generate_video/examples/input/test_input.png)",
    )
    parser.add_argument(
        "--output-file",
        default=str(default_output),
        help="출력 비디오 경로 (기본: generate_video/examples/output/out_test.mp4)",
    )
    parser.add_argument(
        "--prompt",
        default="running man, grab the gun",
        help="비디오 생성 프롬프트",
    )
    parser.add_argument(
        "--negative-prompt",
        default="blurry, low quality, distorted",
        help="네거티브 프롬프트",
    )
    parser.add_argument("--width", type=int, default=480, help="출력 너비")
    parser.add_argument("--height", type=int, default=832, help="출력 높이")
    parser.add_argument("--length", type=int, default=81, help="프레임 길이")
    parser.add_argument("--steps", type=int, default=10, help="디노이징 스텝 수")
    parser.add_argument("--seed", type=int, default=42, help="시드")
    parser.add_argument("--cfg", type=float, default=2.0, help="CFG 스케일")
    parser.add_argument(
        "--context-overlap", type=int, default=48, help="context_overlap 값"
    )
    parser.add_argument(
        "--json",
        "-j",
        help="직접 작성한 input JSON 파일 경로 (원시 input 객체)",
    )

    args = parser.parse_args()

    api_key, endpoint_id = get_config()
    if not api_key or not endpoint_id:
        sys.exit(1)

    # 클라이언트 초기화
    try:
        client = GenerateVideoClient(
            runpod_endpoint_id=endpoint_id,
            runpod_api_key=api_key,
        )
        print(f"✅ 클라이언트 초기화 성공 (endpoint_id={endpoint_id})")
    except Exception as e:
        print("❌ 클라이언트 초기화 실패:", e)
        sys.exit(1)

    # input 구성
    if args.json:
        # JSON 파일을 그대로 input으로 사용하고, /run + /status는 generate_video_client가 처리하지 않으므로
        # 여기서는 /runsync를 직접 호출하지 않고, 단순히 구조 확인용으로만 지원할 수도 있음.
        # 사용성이 애매하니 일단 경고만 출력.
        with open(args.json, encoding="utf-8") as f:
            raw = json.load(f)
        print("현재 test_api.py는 JSON 직접 호출 모드는 지원하지 않고, 파일 내용만 출력합니다.")
        print(json.dumps(raw, indent=2, ensure_ascii=False)[:1200])
        print("\n※ 실제 호출은 generate_video_client 또는 별도 스크립트를 사용하세요.")
        sys.exit(0)

    image_path = Path(args.image_file)
    if not image_path.exists():
        print(f"❌ 입력 이미지가 존재하지 않습니다: {image_path}")
        sys.exit(1)

    print("입력 이미지:", image_path)
    print("출력 비디오:", args.output_file)

    # 비디오 생성
    result = client.create_video_from_image(
        image_path=str(image_path),
        prompt=args.prompt,
        negative_prompt=args.negative_prompt,
        width=args.width,
        height=args.height,
        length=args.length,
        steps=args.steps,
        seed=args.seed,
        cfg=args.cfg,
        context_overlap=args.context_overlap,
        lora_pairs=None,
    )

    status = result.get("status")
    print("\nStatus:", status)

    if status == "COMPLETED":
        ok = client.save_video_result(result, args.output_file)
        if ok:
            print("✅ 비디오 생성 및 저장 완료:", args.output_file)
        else:
            print("❌ 비디오 저장 실패")
        sys.exit(0 if ok else 1)

    print("❌ 작업 실패 또는 미완료:")
    print(json.dumps(result, indent=2, ensure_ascii=False)[:1500])
    sys.exit(1)


if __name__ == "__main__":
    main()

