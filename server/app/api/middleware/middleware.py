import logging
from starlette.requests import Request
from starlette.responses import Response
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.FileHandler('info.log')
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


async def logging_middleware(request: Request, call_next):
    """Middleware để log request/response body"""
    try:
        # Đọc body gốc
        body = await request.body()
        print(f"📥 Request: {request.method} {request.url.path}")
        if body:
            print(f"📥 Body: {body.decode('utf-8')[:500]}")

        # Tạo receive function để trả lại body
        async def receive():
            return {"type": "http.request", "body": body, "more_body": False}

        # Gắn lại request với body
        request = Request(request.scope, receive)

        # Gọi tiếp xuống route
        response: Response = await call_next(request)

        # Đọc response body
        resp_body = b""
        async for chunk in response.body_iterator:
            resp_body += chunk

        print(f"📤 Response: {response.status_code}")
        if resp_body:
            print(f"📤 Body: {resp_body.decode('utf-8')[:500]}")

        # Trả response mới
        return Response(
            content=resp_body,
            status_code=response.status_code,
            headers=dict(response.headers),
            media_type=response.media_type
        )
    except Exception as e:
        print(f"❌ Logging middleware error: {e}")
        return await call_next(request)


class AuthMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        print(f"📨 Request: {request.method} {request.url.path}")
        print(f"🍪 Cookies (client → server): {request.cookies}")

        # ✅ Bước 1: Public routes (bỏ qua auth)
        public_routes = [
            "/api/v1/login",
            "/api/v1/register",
            "/docs",
            "/openapi.json",
            "/",
            "/health",
        ]
        if request.url.path in public_routes:
            print("✅ Public route, skipping auth")
            response = await call_next(request)
        else:
            # ✅ Bước 2: Kiểm tra session
            if "session" not in request.scope:
                print("⚠️ No session in scope")
                return JSONResponse(
                    status_code=401,
                    content={"detail": "No session found - Unauthorized"},
                )

            try:
                session_data = dict(request.session)
                print(f"📦 Session data (decoded): {session_data}")
                user_id = request.session.get("user_id")
            except Exception as e:
                print(f"⚠️ Cannot access session: {e}")
                user_id = None

            if not user_id:
                print("❌ No user_id in session - Unauthorized")
                return JSONResponse(
                    status_code=401,
                    content={"detail": "Unauthorized - Please login"},
                )

            print(f"✅ Authenticated user_id: {user_id}")
            response = await call_next(request)

        # ✅ Bước 3: In Set-Cookie thực tế BE gửi cho client
        print("🍪 Final response headers:")
        for k, v in response.raw_headers:
            print(f"   {k.decode()}: {v.decode()}")

        set_cookie_headers = [
            v.decode()
            for k, v in response.raw_headers
            if k.lower() == b"set-cookie"
        ]
        if set_cookie_headers:
            print("✅ Set-Cookie headers sent to client:")
            for cookie in set_cookie_headers:
                print(f"   → {cookie}")
        else:
            print("⚠️ No Set-Cookie header in response")

        return response