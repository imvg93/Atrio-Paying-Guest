package com.atrio.pg.common.exception;

import com.atrio.pg.common.envelope.ApiError;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import java.util.List;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

/**
 * Renders every failure in the envelope from CLAUDE.md 3.10, reproducing the
 * NestJS {@code AllExceptionsFilter} status-to-code mapping exactly.
 *
 * <p>Authentication and authorization failures raised inside the Spring
 * Security filter chain never reach this class - they are handled by
 * {@code RestAuthenticationEntryPoint} and {@code RestAccessDeniedHandler},
 * which emit the identical envelope.
 */
@RestControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    private static final String INTERNAL_MESSAGE = "Something went wrong. Please try again.";

    /** Deliberate domain errors carry their own code. */
    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ApiError> handleApiException(ApiException ex) {
        return ResponseEntity.status(ex.getStatus())
                .body(ApiError.of(ex.getCode().name(), ex.getMessage()));
    }

    /** Bean Validation on @RequestParam / @PathVariable / @Validated beans. */
    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiError> handleConstraintViolation(ConstraintViolationException ex) {
        List<String> details = ex.getConstraintViolations().stream()
                .map(GlobalExceptionHandler::formatViolation)
                .sorted()
                .toList();
        return ResponseEntity.badRequest()
                .body(ApiError.of(ErrorCode.VALIDATION_ERROR.name(),
                        "Request validation failed.", details));
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ApiError> handleEntityNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiError.of(ErrorCode.NOT_FOUND.name(), ex.getMessage()));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiError> handleDataIntegrity(DataIntegrityViolationException ex) {
        logger.warn("Data integrity violation", ex);
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ApiError.of(ErrorCode.CONFLICT.name(),
                        "The request conflicts with existing data."));
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ApiError> handleAuthentication(AuthenticationException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiError.of(ErrorCode.UNAUTHORIZED.name(), ex.getMessage()));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiError> handleAccessDenied(AccessDeniedException ex) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiError.of(ErrorCode.FORBIDDEN.name(), ex.getMessage()));
    }

    /** Anything unhandled: 500, generic message, full stack logged. */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleUnexpected(Exception ex, WebRequest request) {
        logger.error("Unhandled error on " + request.getDescription(false), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiError.of(ErrorCode.INTERNAL_ERROR.name(), INTERNAL_MESSAGE));
    }

    /** @Valid failure on a request body - carries the per-field details array. */
    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException ex,
            HttpHeaders headers,
            HttpStatusCode status,
            WebRequest request) {

        List<String> details = ex.getBindingResult().getFieldErrors().stream()
                .map(fe -> fe.getField() + " " + fe.getDefaultMessage())
                .sorted()
                .toList();

        return ResponseEntity.badRequest()
                .body(ApiError.of(ErrorCode.VALIDATION_ERROR.name(),
                        "Request validation failed.", details));
    }

    /**
     * A query parameter or path variable that would not convert - a bad UUID, an
     * enum label that does not exist.
     *
     * <p>Spring wraps whatever the converter threw, so the useful message is
     * buried two levels down; an {@link ApiException} raised by a converter
     * (see {@code PgEnumConverterFactory}) is recovered here rather than being
     * reported as "Failed to convert value of type java.lang.String".
     */
    @Override
    protected ResponseEntity<Object> handleTypeMismatch(
            org.springframework.beans.TypeMismatchException ex,
            HttpHeaders headers,
            HttpStatusCode status,
            WebRequest request) {

        String message = null;
        for (Throwable cause = ex.getCause(); cause != null; cause = cause.getCause()) {
            if (cause instanceof ApiException apiException) {
                message = apiException.getMessage();
                break;
            }
        }
        if (message == null) {
            String name = ex instanceof org.springframework.web.method.annotation
                    .MethodArgumentTypeMismatchException mismatch
                    ? mismatch.getName()
                    : "request";
            message = "%s has an unacceptable value.".formatted(name);
        }

        return ResponseEntity.badRequest()
                .body(ApiError.of(ErrorCode.VALIDATION_ERROR.name(), message));
    }

    /**
     * Every other Spring MVC exception (unreadable body, unknown property,
     * missing parameter, method not allowed, ...) funnels through here so it
     * gets the envelope rather than Spring's default ProblemDetail.
     */
    @Override
    protected ResponseEntity<Object> handleExceptionInternal(
            Exception ex,
            Object body,
            HttpHeaders headers,
            HttpStatusCode statusCode,
            WebRequest request) {

        HttpStatus status = HttpStatus.valueOf(statusCode.value());
        ErrorCode code = ErrorCode.forStatus(status);
        String message = ex.getMessage() == null ? status.getReasonPhrase() : ex.getMessage();

        if (status.is5xxServerError()) {
            logger.error("Server error on " + request.getDescription(false), ex);
            message = INTERNAL_MESSAGE;
        }

        return ResponseEntity.status(status)
                .headers(headers)
                .body(ApiError.of(code.name(), message));
    }

    private static String formatViolation(ConstraintViolation<?> v) {
        String path = v.getPropertyPath() == null ? "" : v.getPropertyPath().toString();
        int lastDot = path.lastIndexOf('.');
        String field = lastDot >= 0 ? path.substring(lastDot + 1) : path;
        return (field.isBlank() ? "request" : field) + " " + v.getMessage();
    }
}
