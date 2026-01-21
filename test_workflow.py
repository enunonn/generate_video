import os
import json
import random
from dotenv import load_dotenv
from generate_video_client import GenerateVideoClient

# Load environment variables
load_dotenv()

def strip_quotes(value):
    if value and (value.startswith('"') and value.endswith('"')) or (value.startswith("'") and value.endswith("'")):
        return value[1:-1]
    return value

def load_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def main():
    # Load and clean credentials
    endpoint_id = strip_quotes(os.getenv("RUNPOD_ENDPOINT_ID"))
    api_key = strip_quotes(os.getenv("RUNPOD_API_KEY"))

    if not endpoint_id or not api_key:
        print("[ERROR] Missing configuration. Please set RUNPOD_ENDPOINT_ID and RUNPOD_API_KEY in .env")
        return

    print(f"[OK] Loaded configuration:")
    print(f"  - Endpoint ID: {endpoint_id}")
    
    # Initialize client
    client = GenerateVideoClient(
        runpod_endpoint_id=endpoint_id,
        runpod_api_key=api_key
    )

    # Load workflow template
    workflow_path = "new_Wan22_api.json"
    if not os.path.exists(workflow_path):
        print(f"[ERROR] Workflow file {workflow_path} not found.")
        return
        
    print(f"\n[START] Loading workflow from {workflow_path}")
    workflow = load_json(workflow_path)
    
    # Modify workflow dynamically
    seed = random.randint(100000000000000, 999999999999999)
    prompt_text = "A majestic eagle flying over snow-capped mountains, cinematic lighting, ultra realistic, 8k"
    
    print(f"  - Setting Seed: {seed}")
    print(f"  - Setting Prompt: {prompt_text}")
    
    # Update seed in KSampler (Node 220 and 540 in example)
    if "220" in workflow:
        workflow["220"]["inputs"]["seed"] = seed
    if "540" in workflow:
        workflow["540"]["inputs"]["seed"] = seed
        
    # Update prompt (Node 135)
    if "135" in workflow:
        workflow["135"]["inputs"]["positive_prompt"] = prompt_text
        
    # Prepare inputs
    image_path = "./example_image.png"
    if not os.path.exists(image_path):
        print(f"[ERROR] {image_path} not found.")
        return

    # Helper to clean filename for sending
    filename = os.path.basename(image_path)
    image_base64 = client.encode_file_to_base64(image_path)
    
    # Update LoadImage node (Node 244) to match the filename we will send
    if "244" in workflow:
        workflow["244"]["inputs"]["image"] = filename
        
    images_input = [
        {
            "name": filename,
            "image": image_base64
        }
    ]

    print("\n[START] Submitting Custom Workflow Job...")
    result = client.run_custom_workflow(
        workflow=workflow,
        images_input=images_input
    )

    if result.get('status') == 'COMPLETED':
        output_file = "test_workflow_output.mp4"
        print(f"  - Job completed successfully!")
        
        # Determine output filename from result if possible, or just save the first video
        if client.save_video_result(result, output_file):
            print(f"[SUCCESS] Test Passed! Video saved to {output_file}")
        else:
            print("[ERROR] Failed to save video.")
    else:
        print(f"[FAILED] Test Failed! Status: {result.get('status')}")
        print(f"  - Error: {result.get('error')}")

if __name__ == "__main__":
    main()
