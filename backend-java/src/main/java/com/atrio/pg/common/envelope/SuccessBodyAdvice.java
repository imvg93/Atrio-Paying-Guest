package com.atrio.pg.common.envelope;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;

/**
 * Wraps every successful controller return value in the envelope from
 * CLAUDE.md 3.10, reproducing the NestJS {@code ResponseInterceptor}:
 * <pre>{ "success": true, "data": &lt;return value&gt; }</pre>
 *
 * <p>Scoped to {@code com.atrio.pg} so actuator and springdoc responses are
 * left alone.
 */
@RestControllerAdvice(basePackages = "com.atrio.pg")
@RequiredArgsConstructor
public class SuccessBodyAdvice implements ResponseBodyAdvice<Object> {

    private final ObjectMapper objectMapper;

    @Override
    public boolean supports(MethodParameter returnType,
                            Class<? extends HttpMessageConverter<?>> converterType) {
        return true;
    }

    @Override
    public Object beforeBodyWrite(Object body,
                                  MethodParameter returnType,
                                  MediaType selectedContentType,
                                  Class<? extends HttpMessageConverter<?>> selectedConverterType,
                                  ServerHttpRequest request,
                                  ServerHttpResponse response) {

        // Already enveloped - never double-wrap. Error responses arrive here
        // as ApiError after GlobalExceptionHandler has built them.
        if (body instanceof ApiResponse<?> || body instanceof ApiError) {
            return body;
        }

        // A controller returning a bare String is serialized by
        // StringHttpMessageConverter, which cannot accept an ApiResponse -
        // returning one would throw ClassCastException. Serialize by hand.
        // (MIGRATION_PLAN.md 8.6. Prefer not to return raw String at all.)
        if (StringHttpMessageConverter.class.isAssignableFrom(selectedConverterType)) {
            response.getHeaders().setContentType(MediaType.APPLICATION_JSON);
            try {
                return objectMapper.writeValueAsString(ApiResponse.of(body));
            } catch (JsonProcessingException e) {
                throw new IllegalStateException("Failed to envelope String response", e);
            }
        }

        return ApiResponse.of(body);
    }
}
