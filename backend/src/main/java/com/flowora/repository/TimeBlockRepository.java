package com.flowora.repository;

import com.flowora.entity.TimeBlock;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface TimeBlockRepository extends JpaRepository<TimeBlock, String> {
    List<TimeBlock> findByUserIdAndDateOrderByStartHourAscStartMinuteAsc(String userId, LocalDate date);
    List<TimeBlock> findByUserIdOrderByDateDescStartHourAsc(String userId);
}
