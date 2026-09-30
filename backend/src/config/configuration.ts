const toBool = (value: string | undefined, fallback = false): boolean =>
  value === undefined ? fallback : value.toLowerCase() === 'true';

const toInt = (value: string | undefined, fallback: number): number =>
  value === undefined ? fallback : parseInt(value, 10);

export default () => ({
  env: process.env.NODE_ENV ?? 'development',
  port: toInt(process.env.PORT, 3000),
  apiPrefix: process.env.API_PREFIX ?? 'api/v1',

  database: {
    host: process.env.DB_HOST as string,
    port: toInt(process.env.DB_PORT, 5432),
    username: process.env.DB_USERNAME as string,
    password: process.env.DB_PASSWORD as string,
    name: process.env.DB_NAME as string,
    ssl: toBool(process.env.DB_SSL),
    logging: toBool(process.env.DB_LOGGING),
  },

  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET as string,
    accessTtl: process.env.JWT_ACCESS_TTL ?? '15m',
    refreshSecret: process.env.JWT_REFRESH_SECRET as string,
    refreshTtl: process.env.JWT_REFRESH_TTL ?? '30d',
  },

  otp: {
    ttlSeconds: toInt(process.env.OTP_TTL_SECONDS, 300),
    maxAttempts: toInt(process.env.OTP_MAX_ATTEMPTS, 5),
    requestLimit: toInt(process.env.OTP_REQUEST_LIMIT, 3),
    requestWindowSeconds: toInt(process.env.OTP_REQUEST_WINDOW_SECONDS, 600),
  },

  s3: {
    endpoint: process.env.S3_ENDPOINT ?? '',
    region: process.env.S3_REGION ?? '',
    bucket: process.env.S3_BUCKET ?? '',
    accessKeyId: process.env.S3_ACCESS_KEY_ID ?? '',
    secretAccessKey: process.env.S3_SECRET_ACCESS_KEY ?? '',
    publicBaseUrl: process.env.S3_PUBLIC_BASE_URL ?? '',
  },
});
