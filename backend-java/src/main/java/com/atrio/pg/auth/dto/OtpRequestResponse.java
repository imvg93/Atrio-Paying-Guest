package com.atrio.pg.auth.dto;

/**
 * Response of {@code POST /auth/otp/request}.
 *
 * <p>It carries no secret - the code itself only ever reaches the phone (or,
 * in development, the server log). {@code expiresInSeconds} lets the client
 * show an accurate countdown without hardcoding the TTL.
 *
 * <p>A body is returned rather than {@code 204 No Content} on purpose: the
 * client unwraps every response through the {@code {success, data}} envelope
 * and treats an unenveloped body as a broken contract.
 */
public record OtpRequestResponse(String phone, long expiresInSeconds) {
}
