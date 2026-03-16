# Changelog

## [Unreleased]

### Added
- 일정 삭제 API (`DELETE /schedules`)
  - `ScheduleApiClient.deleteSchedule()`: usersId, schedulesId 요청 바디
- 선택된 날짜 일정 조회 API (`GET /page/schedules/selected`)
  - `ScheduleApiClient.getSelectedDaySchedules()`: usersId, selectedDay(yyyy-mm-dd) 파라미터
  - `SelectedSchedulesResponse`, `SelectedScheduleItemResponse`: API 응답 모델
  - 셀 클릭 시 selected API 호출 후 바텀시트 표시 (로컬 필터링 제거)
  - 바텀시트에서 일정 추가 시 `EventFormScreen(initialDate)`로 선택한 날짜 전달
- 일정 API 연동 (`/page/schedules/search`)
  - `ScheduleApiClient`: startDate~endDate 범위로 일정 검색
  - `ScheduleSearchResponse`, `ScheduleItemResponse`: API 응답 모델
  - `.env`로 API Base URL 관리 (git 미포함), `.env.example` 템플릿 제공
  - `CalendarController.loadEvents()`: 월별 일정 로드
  - 캘린더 화면 진입 시 및 월 변경 시 API에서 일정 자동 로드
- 공통 위젯 분리 (`lib/views/widgets/common/`)
  - `AppDivider`: 앱 전역 구분선
  - `TappableRow`: 탭 가능한 행 (화살표 포함)
  - `BottomBarButton`: 하단 바 버튼
- 이벤트 위젯 분리 (`lib/views/widgets/event/`)
  - `EventSection`: 섹션 레이아웃 컨테이너
  - `EventTimeSection`: 시간 설정 섹션
  - `EventTimeRow`: 시간 행 위젯
  - `EventFolderSection`: 보관함 섹션
  - `EventLocationSection`: 위치 섹션
  - `EventAlarmSection`: 알림 섹션
  - `EventMemoSection`: 메모 섹션
- `EventFormController`: 이벤트 폼 상태 관리 (Riverpod)
- `EventFormScreen`: 일정 추가/수정 화면 (통합)

### Fixed
- 일정 추가 후 캘린더 셀 클릭 시 "Invalid date format" 예외 발생 문제
  - 원인: 바텀시트가 월별 검색 데이터를 필터링해 사용 (잘못된 데이터 소스)
  - 해결: 셀 클릭 시 `GET /page/schedules/selected` API 호출로 해당 날짜 일정 직접 조회

### Removed

### Changed
- `EventDetailScreen`: 분리된 위젯 사용하도록 리팩토링
- 위젯들에 `isEditable` 속성 추가로 상세/폼 화면 공유 가능
- `EventDetailScreen`: 인라인 편집 모드 구현
  - 수정 버튼 클릭 시 별도 화면 이동 대신 같은 화면에서 편집 모드 전환
  - 편집 모드 진입 시 타이틀에 자동 포커스 (키보드 올라옴)
  - 편집 모드에서 저장/취소 버튼 제공
