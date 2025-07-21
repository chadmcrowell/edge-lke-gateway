import { httpRequest } from 'http-request';
import { createResponse } from 'create-response';

function isValidToken(token) {
  return token && token.startsWith("Bearer ");
}

export async function responseProvider(request) {
  const token = request.getHeader('Authorization');

  if (!isValidToken(token)) {
    return createResponse(401, {}, "Unauthorized");
  }

  const response = await httpRequest({
    method: request.method,
    url: `https://api.myapp.lat${request.url.pathname}`,
    headers: request.getHeaders()
  });

  return response.toResponse();
}
