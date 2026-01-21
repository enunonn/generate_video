import os
import time
from dotenv import load_dotenv
from generate_video_client import GenerateVideoClient

# Load environment variables
load_dotenv()

def strip_quotes(value):
    if value and (value.startswith('"') and value.endswith('"')) or (value.startswith("'") and value.endswith("'")):
        return value[1:-1]
    return value

def main():
    # Load and clean credentials
    endpoint_id = strip_quotes(os.getenv("RUNPOD_ENDPOINT_ID"))
    api_key = strip_quotes(os.getenv("RUNPOD_API_KEY"))

    if not endpoint_id or not api_key:
        print("[ERROR] Missing configuration. Please set RUNPOD_ENDPOINT_ID and RUNPOD_API_KEY in .env")
        return

    print(f"[OK] Loaded configuration:")
    print(f"  - Endpoint ID: {endpoint_id}")
    print(f"  - API Key: {api_key[:8]}...{api_key[-4:]}")

    # Initialize client
    client = GenerateVideoClient(
        runpod_endpoint_id=endpoint_id,
        runpod_api_key=api_key
    )

    print("\n[START] Test: Generating video from example_image.png")
    
    # Check if example image exists
    image_path = "./example_image.png"
    if not os.path.exists(image_path):
        print(f"[ERROR] {image_path} not found.")
        return

    # Submit job
    print("  - Submitting job...")
    result = client.create_video_from_image(
        image_path=image_path,
        prompt="A cinematic shot of a cyberpunk city at night, neon lights, rain, 4k, highly detailed",
        width=480,
        height=832,
        length=81,
        steps=10,
        seed=42
    )

    if result.get('status') == 'COMPLETED':
        output_file = "test_output.mp4"
        print(f"  - Job completed successfully!")
        if client.save_video_result(result, output_file):
            print(f"[SUCCESS] Test Passed! Video saved to {output_file}")
        else:
            print("[ERROR] Failed to save video.")
    else:
        print(f"[FAILED] Test Failed! Status: {result.get('status')}")
        print(f"  - Error: {result.get('error')}")

if __name__ == "__main__":
    main()
