export function handler(req, res) {
  res.status(200).json({ status: 'ok', service: 'auth' });
}

export function healthCheck() {
  return { status: 'healthy' };
}
