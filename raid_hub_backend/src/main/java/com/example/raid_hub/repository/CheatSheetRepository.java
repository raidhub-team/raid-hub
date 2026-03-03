package com.example.raid_hub.repository;

import com.example.raid_hub.entity.CheatSheet;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CheatSheetRepository extends JpaRepository<CheatSheet, Long> {
  List<CheatSheet> findByRaidName(String raidName);
}
