import aiohttp
import json
from typing import List, Dict, Any

class LLMService:
    def __init__(self, api_key: str, base_url: str):
        self.api_key = api_key
        self.base_url = base_url
        self.session = None

    async def _get_session(self):
        if self.session is None:
            self.session = aiohttp.ClientSession()
        return self.session

    async def close(self):
        if self.session:
            await self.session.close()

    # PHƯƠNG THỨC CŨ (giữ lại để tương thích)
    async def generate_response(self, message: str, model: str) -> Dict[str, Any]:
        """Generate response from a single message"""
        messages = [{"role": "user", "content": message}]
        return await self.generate_response_with_messages(messages, model)

    # PHƯƠNG THỨC MỚI (hỗ trợ system prompt + conversation history)
    async def generate_response_with_messages(self, messages: List[Dict[str, str]], model: str) -> Dict[str, Any]:
        """Generate response from messages array (OpenAI format)"""
        session = await self._get_session()
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 1000,
            "stream": False
        }
        
        try:
            async with session.post(
                f"{self.base_url}/chat/completions",
                headers=headers,
                json=payload
            ) as response:
                
                if response.status == 200:
                    data = await response.json()
                    
                    return {
                        "response": data["choices"][0]["message"]["content"],
                        "usage": data.get("usage", {}),
                        "model": data.get("model", model)
                    }
                else:
                    error_text = await response.text()
                    raise Exception(f"API Error {response.status}: {error_text}")
                    
        except Exception as e:
            print(f"Error calling Groq API: {str(e)}")
            return {
                "response": f"Xin lỗi, đã có lỗi xảy ra: {str(e)}",
                "usage": {},
                "model": model
            }