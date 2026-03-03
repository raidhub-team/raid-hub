package com.example.raid_hub.controller;

import com.example.raid_hub.entity.CheatSheet;
import com.example.raid_hub.service.CheatSheetService;
import java.io.IOException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/cheatsheets")
@RequiredArgsConstructor
public class CheatSheetController {

  private final CheatSheetService cheatSheetService;

  @PostMapping
  public ResponseEntity<CheatSheet> uploadCheatSheet(
      @RequestParam String title,
      @RequestParam String raidName,
      @RequestParam String gate,
      @RequestParam String uploaderName,
      @RequestParam MultipartFile file)
      throws IOException {

    CheatSheet savedCheatSheet =
        cheatSheetService.uploadCheatSheet(title, raidName, gate, uploaderName, file);
    return ResponseEntity.ok(savedCheatSheet);
  }

  @GetMapping
  public ResponseEntity<List<CheatSheet>> getAllCheatSheets() {
    return ResponseEntity.ok(cheatSheetService.getAllCheatSheets());
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteCheatSheet(@PathVariable Long id) {
    cheatSheetService.deleteCheatSheet(id);
    return ResponseEntity.noContent().build();
  }
}
