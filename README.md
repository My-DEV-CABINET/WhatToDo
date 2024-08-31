# WhatToDo

<img src="https://velog.velcdn.com/images/jakkujakku98/post/328b52be-2d8d-4282-8ae6-3e594a2af6ed/image.png">

# 1. 소개 및 기간

### 1.1 소개

- 온라인 서버와 앱간의 네트워크 통신을 통해 할일을 저장/조회/수정/삭제할 수 있는 서비스입니다.

### 1.2 개발 기간 (총 6주)

- **1차** : 2024.06.16 - 2024.06.23 (1주)
  - Code-Based UI
    - 할일 조회/상세/편집 페이지 생성
  - Combine 사용
- **2차** : 2024.06.25 - 2024.07.02 (1주)
  - Code-Based UI -> StoryBoard
    - Code를 사용하여 UI를 구현하는 것보다, StoryBoard를 사용하는 것이 더 빨리 구현하기 위해 변경함.
    - 필터 페이지
- **3차** : 2024.07.12 - 2024.07.19 (1주)
  - Combine -> RxSwift, RxDatasource 사용
    - 기존 Combine과 달리 Rx는 바로 UI에 Binding 하여, 사용할 수 있는 점에서 코드를 유지보수 용이하다는 것과 RxDatasource와 연계하여 사용할 수 있다는 것에서 장점을 보아 적용
  - Tuist 사용
    - 프로젝트를 모듈 단위로 나누어 프로젝트를 관리하기 위해 사용
- **4차** : 2024.07.19 - 2024.07.26 (1주)
  - SQLite 사용
    - 조회 내역과, 북마크 저장 기능을 사용하기 위해 SQLite 사용
  - UserDefault를 사용하여 필터 처리 기능 구현
- **5차** : 2024.08.01 - 2024.08.14 (2주)
  - 검색 페이지 & 알림 내역 페이지 구현
    - RealmSwift를 사용하여, 검색한 내역과 알림 내역을 저장/삭제 기능을 구현함.
  - SQLite -> RealmSwift 사용
    - 기존 SQLite는 저장된 내역을 볼 수가 없다는 것과 스위프트로 관리하는 것보다 SQL구문으로 관리하는 것이 향후 유지보수에 어려움을 줄 수 있다 생각함.
      RealmSwift는 SQLite가 가지고 있는 문제점들을 해결해줄 수 있다고 생각되어 사용하기로 결정함.
  - Tuist 폐기
    - 기존 Tuist를 도입하기로 한 목표는 "프로젝트를 모듈 단위로 나누어 프로젝트를 관리"가 목표인데 달성하지 못한 부분과 깃허브에 올리기 위해 잦은 clean 명령어로 인하여 Tuist자체에서의 빌드 오류 문제를 겪어 프로젝트에서 분리하기로 결정함.
  - Lottie Animation 사용
    - 앱 시작시 런치 스크린이 보이면서, Lottie 애니메이션이 보이게 하기 위해 사용

## 2. 목표와 기능

### 2.1 목표

- Online
  - REST API를 활용하여, 서버에 할일을 조회/추가/편집/삭제할 수 있게 하는 것
- Local
  - RealmSwift를 활용하여, 조회/알림/검색 내역을 처리할 수 있게 하는 것
  - UserDefaults를 활용하여, 할일 필터를 처리할 수 있게 하는 것

### 2.2 기능

- 할일 조회 페이지 & 필터 페이지
  - 할일을 오름차순/내림차순 정렬 할 수 있습니다.
  - 할일을 모두보기/완료/미완료 선택하여 볼수 있습니다.
- 할일 작성 페이지
  - 할일을 작성할 수 있습니다.
- 할일 상세 페이지
  - 할일 편집/삭제 할 수 있습니다.
- 검색 페이지
  - 할일을 검색할 수 있습니다.
  - 저장된 검색 내역들을 확인/삭제 할 수 있습니다.

- 알림 내역 페이지
  - 할일을 추가/삭제할 경우 발생한 알림들을 확인할 수 있습니다.

## 3. 개발 환경

### 3.1 개발 환경 및 배포 URL

- 버전 정보
  - iOS 16.5 이상
- 라이브러리 및 프레임워크
  - RxSwift
  - RxDatasource
  - Alamofire
  - RealmSwift
  - Lottie


### 3.2 Secret.config (API Key 명세서)

- API Key 입력 안내

```
1. Secrets.Example.xcconfig 파일명 중 Example 를 제거하세요. 
Ex)Secrets.Example.xcconfig -> Secrets.xcconfig

2. xcconfig 파일 내용들을 안내에 맞춰 바꿔주세요.
Ex)SCHEME = "www"
```



## 4. UI

### 4.1 페이지별 UI

<table>
    <tbody>
        <tr>
            <td>앱 시작 페이지</td>
            <td>할일 조회 페이지</td>
        </tr>
        <tr>
            <td>
        <img src="https://velog.velcdn.com/images/jakkujakku98/post/2d69c1ac-8d43-4d7b-8d33-faedfcb1ddf4/image.jpeg" width="100%">
            </td>
            <td>
                <img src="https://velog.velcdn.com/images/jakkujakku98/post/716d4f3f-13cb-46b0-bdef-e5aa2d8b7cb8/image.jpeg" width="100%">
            </td>
        </tr>
        <tr>
            <td>할일 작성 페이지</td>
            <td>할일 상세 & 편집 페이지</td>
        </tr>
        <tr>
            <td>
                <img src="https://velog.velcdn.com/images/jakkujakku98/post/141525f8-9ac2-4dec-a799-53eeb5cb53cc/image.jpeg" width="100%">
            </td>
            <td>
                <img src="https://velog.velcdn.com/images/jakkujakku98/post/73481a4f-a072-4471-89c5-7a70f5514f7e/image.jpeg" width="100%">
            </td>
        </tr>
      <tr>
            <td>할일 검색 페이지</td>
            <td>할일 알림 페이지</td>
        </tr>
        <tr>
            <td>
        <img src="https://velog.velcdn.com/images/jakkujakku98/post/55f8f227-03ab-402f-ad88-acfa6fdccdea/image.jpeg" width="100%">
            </td>
            <td>
                <img src="https://velog.velcdn.com/images/jakkujakku98/post/32b5f632-9523-4b60-b7d2-b8b7fe834f78/image.jpeg" width="100%">
            </td>
        </tr>
       <tr>
            <td>할일 필터 페이지</td>
        </tr>
        <tr>
            <td>
        <img src="https://velog.velcdn.com/images/jakkujakku98/post/c197904c-6a92-496d-a0cf-3f70e679c643/image.jpeg" width="100%">
            </td>
        </tr>
    </tbody>
</table>

