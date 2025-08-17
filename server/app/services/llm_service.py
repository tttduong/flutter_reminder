import asyncio
import httpx
from fastapi import HTTPException
from tenacity import retry, stop_after_attempt, wait_exponential
import logging

logger = logging.getLogger(__name__)

class LLMService:
    def __init__(self, api_key: str, base_url: str):
        self.api_key = api_key
        self.base_url = base_url
        self.client = httpx.AsyncClient(timeout=30.0)
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        reraise=True
    )
    async def call_llm_with_retry(self, prompt: str, model: str = "llama3-70b-8192"):
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": 1024,
            "temperature": 0.7
        }
        
        try:
            logger.info(f"Calling Groq API with prompt length: {len(prompt)}")
            
            response = await self.client.post(
                f"{self.base_url}/chat/completions",
                json=payload,
                headers=headers
            )
            
            response.raise_for_status()
            result = response.json()
            logger.info("Groq API call successful")
            
            return result
            
        except httpx.HTTPStatusError as e:
            logger.error(f"HTTP error: {e.response.status_code}")
            if e.response.status_code == 429:
                logger.warning("Rate limit hit, retrying...")
                raise
            elif e.response.status_code >= 500:
                logger.warning("Server error, retrying...")
                raise
            else:
                raise HTTPException(
                    status_code=e.response.status_code,
                    detail=f"Groq API error: {e.response.text}"
                )
                
        except httpx.TimeoutException:
            logger.warning("Request timeout, retrying...")
            raise
            
        except httpx.RequestError as e:
            logger.error(f"Request error: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Network error: {str(e)}")
    
    async def generate_response(self, prompt: str, model: str = "llama3-70b-8192"):
        try:
            result = await self.call_llm_with_retry(prompt, model)
            
            if "choices" in result and len(result["choices"]) > 0:
                response_text = result["choices"][0]["message"]["content"]
                return {
                    "response": response_text,
                    "usage": result.get("usage", {}),
                    "model": result.get("model", model)
                }
            else:
                raise HTTPException(status_code=500, detail="Invalid response from Groq")
                
        except Exception as e:
            logger.error(f"Error generating response: {str(e)}")
            if isinstance(e, HTTPException):
                raise
            else:
                raise HTTPException(status_code=500, detail="Internal server error")
    
    async def close(self):
        await self.client.aclose()