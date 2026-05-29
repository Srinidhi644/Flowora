package com.flowora.controller;

import com.flowora.dto.AuthRequest;
import com.flowora.dto.AuthResponse;
import com.flowora.entity.User;
import com.flowora.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody AuthRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @GetMapping("/me")
    public ResponseEntity<User> me(Authentication auth) {
        User user = authService.getUser(auth.getPrincipal().toString());
        user.setPassword(null); // Don't expose password
        return ResponseEntity.ok(user);
    }

    @PutMapping("/profile")
    public ResponseEntity<User> updateProfile(Authentication auth,
                                               @RequestBody Map<String, String> body) {
        String userId = auth.getPrincipal().toString();
        User user = authService.updateProfile(userId, body.get("name"), body.get("dietaryPreference"));
        user.setPassword(null);
        return ResponseEntity.ok(user);
    }
}
