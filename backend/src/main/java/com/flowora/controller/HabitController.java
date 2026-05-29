package com.flowora.controller;

import com.flowora.dto.HabitDto;
import com.flowora.entity.Habit;
import com.flowora.service.HabitService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/habits")
@RequiredArgsConstructor
public class HabitController {

    private final HabitService service;

    @GetMapping
    public List<Habit> getAll(Authentication auth) {
        return service.getAllByUser(userId(auth));
    }

    @PostMapping
    public Habit create(Authentication auth, @RequestBody HabitDto dto) {
        return service.create(userId(auth), dto);
    }

    @PutMapping("/{id}")
    public Habit update(Authentication auth, @PathVariable String id, @RequestBody HabitDto dto) {
        return service.update(userId(auth), id, dto);
    }

    @PostMapping("/{id}/log")
    public Habit log(Authentication auth, @PathVariable String id, @RequestBody HabitDto.LogDto logDto) {
        return service.logToday(userId(auth), id, logDto);
    }

    @PatchMapping("/{id}/toggle")
    public Habit toggle(Authentication auth, @PathVariable String id) {
        return service.toggleToday(userId(auth), id);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(Authentication auth, @PathVariable String id) {
        service.delete(userId(auth), id);
        return ResponseEntity.noContent().build();
    }

    private String userId(Authentication auth) {
        return auth.getPrincipal().toString();
    }
}
