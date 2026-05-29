package com.flowora.service;

import com.flowora.dto.TimeBlockDto;
import com.flowora.entity.TimeBlock;
import com.flowora.repository.TimeBlockRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TimeBlockService {

    private final TimeBlockRepository repo;

    public List<TimeBlock> getAllByUser(String userId) {
        return repo.findByUserIdOrderByDateDescStartHourAsc(userId);
    }

    public List<TimeBlock> getByDate(String userId, LocalDate date) {
        return repo.findByUserIdAndDateOrderByStartHourAscStartMinuteAsc(userId, date);
    }

    public TimeBlock create(String userId, TimeBlockDto dto) {
        TimeBlock block = TimeBlock.builder()
                .userId(userId)
                .date(dto.getDate())
                .startHour(dto.getStartHour())
                .startMinute(dto.getStartMinute())
                .endHour(dto.getEndHour())
                .endMinute(dto.getEndMinute())
                .type(dto.getType())
                .label(dto.getLabel())
                .build();
        return repo.save(block);
    }

    public TimeBlock update(String userId, String blockId, TimeBlockDto dto) {
        TimeBlock block = repo.findById(blockId)
                .orElseThrow(() -> new RuntimeException("TimeBlock not found"));
        if (!block.getUserId().equals(userId)) throw new RuntimeException("Unauthorized");

        if (dto.getDate() != null) block.setDate(dto.getDate());
        block.setStartHour(dto.getStartHour());
        block.setStartMinute(dto.getStartMinute());
        block.setEndHour(dto.getEndHour());
        block.setEndMinute(dto.getEndMinute());
        if (dto.getType() != null) block.setType(dto.getType());
        if (dto.getLabel() != null) block.setLabel(dto.getLabel());

        return repo.save(block);
    }

    public void delete(String userId, String blockId) {
        TimeBlock block = repo.findById(blockId)
                .orElseThrow(() -> new RuntimeException("TimeBlock not found"));
        if (!block.getUserId().equals(userId)) throw new RuntimeException("Unauthorized");
        repo.delete(block);
    }
}
