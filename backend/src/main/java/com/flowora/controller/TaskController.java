package com.flowora.controller;

import com.flowora.dto.TaskDto;
import com.flowora.entity.Task;
import com.flowora.service.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService service;

    @GetMapping
    public List<Task> getAll(Authentication auth) {
        return service.getAllByUser(userId(auth));
    }

    @GetMapping("/date/{date}")
    public List<Task> getByDate(Authentication auth,
                                @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return service.getByDate(userId(auth), date);
    }

    @GetMapping("/overdue")
    public List<Task> getOverdue(Authentication auth) {
        return service.getOverdue(userId(auth));
    }

    @PostMapping
    public Task create(Authentication auth, @RequestBody TaskDto dto) {
        return service.create(userId(auth), dto);
    }

    @PutMapping("/{id}")
    public Task update(Authentication auth, @PathVariable String id, @RequestBody TaskDto dto) {
        return service.update(userId(auth), id, dto);
    }

    @PatchMapping("/{id}/toggle")
    public Task toggle(Authentication auth, @PathVariable String id) {
        return service.toggleComplete(userId(auth), id);
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
