import 'reflect-metadata';
import { Logger, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, { bufferLogs: false });
  const config = app.get(ConfigService);

  // Every route lives under /api/v1 — CLAUDE.md §3.8.
  app.setGlobalPrefix(config.get<string>('apiPrefix', 'api/v1'));

  // CLAUDE.md §3.12: reject anything not declared on a DTO.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: false },
    }),
  );

  // CLAUDE.md §3.10: one response envelope, success and failure.
  app.useGlobalInterceptors(new ResponseInterceptor());
  app.useGlobalFilters(new AllExceptionsFilter());

  app.enableShutdownHooks();

  const port = config.get<number>('port', 3000);
  await app.listen(port);

  Logger.log(
    `API listening on http://localhost:${port}/${config.get<string>('apiPrefix', 'api/v1')}`,
    'Bootstrap',
  );
}

void bootstrap();
