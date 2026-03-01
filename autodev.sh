#!/bin/bash

# ============================================
# AUTODEV - Continuous Claude Code Dev Loop
# for StudyNotebook Flutter App
# ============================================

MAX_TURNS=50
PAUSE_BETWEEN_CYCLES=15
LOG_FILE="autodev.log"
AUTO_COMMIT=true
MODEL="sonnet"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="${1:-.}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Directory '$PROJECT_DIR' not found${NC}"
    exit 1
fi

cd "$PROJECT_DIR" || exit 1
echo -e "${GREEN}=== AUTODEV started at $(date) ===${NC}"
echo -e "Project: $(pwd)"
echo ""

PROMPT='You are an autonomous developer working on the StudyNotebook Flutter app.

INSTRUCTIONS:
1. First, read TODO.md (create it if missing) and CLAUDE.md for project conventions.
2. Read through the codebase to understand the current state.
3. Pick the highest priority incomplete task from TODO.md.
4. Implement it fully — write code, fix bugs, improve UI.
5. After completing the task, mark it done in TODO.md with [x] and the date.
6. Run "flutter analyze" to check for issues. Fix any that appear.
7. Run "flutter test" to ensure nothing is broken. Fix failures.
8. If all tasks are done, do a full review and:
   - Fix any bugs you find
   - Improve UI polish and consistency
   - Improve code quality and error handling
   - Add missing features that would be valuable
   - Update TODO.md with new improvement tasks
9. Append a brief summary of what you did to CHANGELOG.md.

RULES:
- Focus on ONE task per cycle. Do it well.
- Always run flutter analyze and flutter test after changes.
- Do not break existing functionality.
- Keep changes focused and reviewable.
- Follow the conventions in CLAUDE.md (Riverpod, GoRouter, freezed models, etc.).'

CYCLE=0

while true; do
    CYCLE=$((CYCLE + 1))
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Cycle #$CYCLE | $TIMESTAMP${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo "[$TIMESTAMP] Cycle #$CYCLE started" >> "$LOG_FILE"

    claude -p "$PROMPT" \
        --model "$MODEL" \
        --allowedTools "Edit,Write,Bash,Read,Glob,Grep" \
        --max-turns "$MAX_TURNS" \
        2>&1 | tee -a "$LOG_FILE"

    EXIT_CODE=$?
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ $EXIT_CODE -ne 0 ]; then
        echo -e "${RED}[$TIMESTAMP] Cycle #$CYCLE failed (exit $EXIT_CODE)${NC}"
        echo "[$TIMESTAMP] Cycle #$CYCLE FAILED ($EXIT_CODE)" >> "$LOG_FILE"
        if [ $EXIT_CODE -eq 1 ]; then
            echo -e "${YELLOW}Possible rate limit. Waiting 5 minutes...${NC}"
            sleep 300
            continue
        fi
    else
        echo -e "${GREEN}[$TIMESTAMP] Cycle #$CYCLE completed${NC}"
        echo "[$TIMESTAMP] Cycle #$CYCLE completed" >> "$LOG_FILE"
    fi

    if [ "$AUTO_COMMIT" = true ] && [ -d ".git" ]; then
        if ! git diff --quiet HEAD 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
            git add -A
            git commit -m "autodev: cycle #$CYCLE - $(date '+%Y-%m-%d %H:%M')" --no-verify
            echo -e "${GREEN}Changes committed${NC}"
        fi
    fi

    echo -e "${YELLOW}Pausing ${PAUSE_BETWEEN_CYCLES}s...${NC}"
    sleep "$PAUSE_BETWEEN_CYCLES"
done
