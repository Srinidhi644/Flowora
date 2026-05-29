package com.flowora.controller;

import com.flowora.dto.TimeBlockDto;
import com.flowora.entity.TimeBlock;
import com.flowora.service.TimeBlockService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/time-blocks")
@RequiredArgsConstructor
public class TimeBlockController {

    private final TimeBlockService service;

    @GetMapping
    public List<TimeBlock> getAll(Authentication auth) {
        return service.getAllByUser(userId(auth));
    }

    @GetMapping("/date/{date}")
    public List<TimeBlock> getByDate(Authentication auth,
                                      @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return service.getByDate(userId(auth), date);
    }

    @PostMapping
    public TimeBlock create(Authentication auth, @RequestBody TimeBlockDto dto) {
        return service.create(userId(auth), dto);
    }

    @PutMapping("/{id}")
    public TimeBlock update(Authentication auth, @PathVariable String id, @RequestBody TimeBlockDto dto) {
        return service.update(userId(auth), id, dto);
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
