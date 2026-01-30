import requests
import json

def test_model(model_name, api_key):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
    headers = {"Content-Type": "application/json"}
    payload = {
        "contents": [{"parts": [{"text": "Say 'Success' if you can read this."}]}]
    }
    
    print(f"--- Testing {model_name} ---")
    try:
        response = requests.post(url, headers=headers, data=json.dumps(payload))
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            if 'candidates' in data and data['candidates']:
                answer = data['candidates'][0]['content']['parts'][0]['text']
                print(f"RESPONSE: {answer.strip()}")
            else:
                print(f"NO CANDIDATES IN RESPONSE: {data}")
        else:
            print(f"ERROR BODY: {response.text}")
    except Exception as e:
        print(f"EXCEPTION: {e}")
    print("\n")

if __name__ == "__main__":
    API_KEY = "AIzaSyBAvZ8Wzho8Dgg3fSfe1x7vRZvcdE5Ql8s"
    test_model("gemini-2.5-flash", API_KEY)
    test_model("gemini-2.0-flash-lite", API_KEY)
