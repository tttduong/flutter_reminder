import logging
# from fastapi import Request
from starlette.requests import Request
from starlette.responses import Response

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.FileHandler('info.log')
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


# async def logging_middleware(request: Request, call_next):
#     logger.info(f"Incoming request: {request.method} {request.url.path}")
#     response = await call_next(request)
#     logger.info(f"Outgoing response code: {response.status_code}")
#     return response

async def logging_middleware(request: Request, call_next):
    # đọc body gốc
    body = await request.body()
    print("📥 Request body:", body.decode("utf-8"))

    # tạo receive async function để trả lại body cho downstream
    async def receive():
        return {"type": "http.request", "body": body, "more_body": False}

    # gắn lại request với body
    request = Request(request.scope, receive)

    # gọi tiếp xuống route
    response: Response = await call_next(request)

    # đọc response body
    resp_body = b""
    async for chunk in response.body_iterator:
        resp_body += chunk

    print("📤 Response body:", resp_body.decode("utf-8"))

    # trả response mới (để client vẫn nhận được body)
    return Response(
        content=resp_body,
        status_code=response.status_code,
        headers=dict(response.headers),
        media_type=response.media_type
    )

