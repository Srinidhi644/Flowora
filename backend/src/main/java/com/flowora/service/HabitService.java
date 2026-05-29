package com.flowora.service;

import com.flowora.dto.HabitDto;
import com.flowora.entity.Habit;
import com.flowora.entity.HabitLog;
import com.flowora.repository.HabitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HabitService {

    private final HabitRepository repo;

    public List<Habit> getAllByUser(String userId) {
        return repo.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public Habit create(String userId, HabitDto dto) {
        Habit habit = Habit.builder()
                .userId(userId)
                .name(dto.getName())
                .icon(dto.getIcon() != null ? dto.getIcon() : "check_circle")
                .type(dto.getType() != null ? dto.getType() : Habit.HabitType.BOOLEAN)
                .targetValue(dto.getTargetValue())
                .unit(dto.getUnit())
                .build();
        return repo.save(habit);
    }

    public Habit update(String userId, String habitId, HabitDto dto) {
        Habit habit = getOwnedHabit(userId, habitId);

        if (dto.getName() != null) habit.setName(dto.getName());
        if (dto.getIcon() != null) habit.setIcon(dto.getIcon());
        if (dto.getType() != null) habit.setType(dto.getType());
        if (dto.getTargetValue() != null) habit.setTargetValue(dto.getTargetValue());
        if (dto.getUnit() != null) habit.setUnit(dto.getUnit());

        return repo.save(habit);
    }

    @Transactional
    public Habit logToday(String userId, String habitId, HabitDto.LogDto logDto) {
        Habit habit = getOwnedHabit(userId, habitId);
        LocalDate date = logDto.getDate() != null ? logDto.getDate() : LocalDate.now();

        // Remove existing log for that date
        habit.getLogs().removeIf(l -> l.getDate().equals(date));

        HabitLog log = HabitLog.builder()
                .date(date)
                .completed(logDto.isCompleted())
                .value(logDto.getValue())
                .habit(habit)
                .build();
        habit.getLogs().add(log);

        return repo.save(habit);
    }

    @Transactional
    public Habit toggleToday(String userId, String habitId) {
        Habit habit = getOwnedHabit(userId, habitId);
        LocalDate today = LocalDate.now();

        var existing = habit.getLogs().stream()
                .filter(l -> l.getDate().equals(today))
                .findFirst();

        if (existing.isPresent()) {
            existing.get().setCompleted(!existing.get().isCompleted());
        } else {
            HabitLog log = HabitLog.builder()
                    .date(today)
                    .completed(true)
                    .habit(habit)
                    .build();
            habit.getLogs().add(log);
        }

        return repo.save(habit);
    }

    public void delete(String userId, String habitId) {
        Habit habit = getOwnedHabit(userId, habitId);
        repo.delete(habit);
    }

    private Habit getOwnedHabit(String userId, String habitId) {
        Habit habit = repo.findById(habitId)
                .orElseThrow(() -> new RuntimeException("Habit not found"));
        if (!habit.getUserId().equals(userId)) throw new RuntimeException("Unauthorized");
        return habit;
    }
}
