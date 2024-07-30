# WhatToDo

# 1. 소개 및 기간

### 1.1 소개

- 온라인 서버와 앱간의 네트워크 통신을 통해 할일을 저장/조회/수정/삭제할 수 있는 서비스입니다.

### 1.2 개발 기간

- **1차** : 2024.05.16 - 2024.05.23 (1주)
- **2차** : 2024.05.31 - 2024.06.12 (12일)
- **3차** : 2024.06.12 - 2024.06.19 (1주)
- **4차** : 2024.06.19 - 2024.06.26 (1주)
- **5차** : 2024.06.26 - 현재 진행 중

## 2. 목표와 기능

### 2.1 목표

- REST API 를 사용하여, 온라인으로 할일을 관리할 수 있게 하는 것

### 2.2 기능

- 할일 리스트 페이지
  - 할일을 오름차순/내림차순 정렬 할 수 있습니다.
  - 할일을 모두보기/완료/미완료 선택하여 볼수 있습니다.
  - 북마크와 할일 조회 기록을 저장/삭제 할 수 있습니다.

- 할일 작성 페이지
  - 할일을 작성할 수 있습니다.

- 할일 상세 페이지
  - 할일 편집/삭제 할 수 있습니다.

## 3. 개발 환경

### 3.1 개발 환경 및 배포 URL

- 버전 정보
  - iOS 16.0 이상
- 라이브러리 및 프레임워크
  - RxSwift
  - RxDatasource
  - Alamofire
  - SQLite


### 3.2 Secret.config (API Key 명세서)

- API Key 입력 안내

```
1. Secrets.Example.xcconfig 파일명 중 Example 를 제거하세요. 
Ex)Secrets.Example.xcconfig -> Secrets.xcconfig

2. xcconfig 파일 내용들을 안내에 맞춰 바꿔주세요.
Ex)SCHEME = "www"
```



## 4. UI

### 4.1 페이지별 UI(업데이트 예정)

<table>
    <tbody>
        <tr>
            <td>할일 조회 페이지</td>
            <td>할일 작성 페이지</td>
        </tr>
        <tr>
            <td>
		<img src="ui1.png" width="100%">
            </td>
            <td>
                <img src="ui2.png" width="100%">
            </td>
        </tr>
        <tr>
            <td>할일 편집 페이지</td>
            <td>설정 페이지</td>
        </tr>
        <tr>
            <td>
                <img src="ui3.png" width="100%">
            </td>
            <td>
                <img src="ui3.png" width="100%">
            </td>
        </tr>
    </tbody>
</table>

## 5. 에러와 에러 해결

- 페이징 처리

  ## 상황(Situation) : 문제 상황 설명

  셀을 아래로 내릴 때, 페이징 처리 고민

  - 1,2,3 번호를 눌러서 화면 이동
  - 무한 스크롤링

  ## 목표(Task) : 해결 목표

  사용자가 번거롭게 계속 1,2,3 을 클릭하는 것은 모바일 환경에서 UX에 번거로움을 유발함.

  그래서 화면 아래로 계속 스크롤 할 때 자동으로 데이터를 갱신하여 추가하는 방식을 구현(참조: 당근 마켓 스크롤링)

  스크롤뷰의 80% 정도 스크롤할 시, 데이터를 호출하는 것이 목표!!

  ## 행동(Action) : 문제 해결 과정 or 시도

  스크롤뷰를 감지하는 방식과 몇번째 셀이 나타나는지를 감지하는 방식이 있음.

  스크롤뷰의 Offset을 사용하여, 페이징처리 방식의 특징(`DidScroll`)

  - 스크롤뷰의 Offset 을 사용하여, 현재 스크롤뷰에서의 나의 위치와 스크롤뷰의 사이즈를 쉽게 파악이 가능함.
  - 페이징 처리를 하기 위해서, 별도의 작업 처리를 더 해줘야함.

  몇번째 셀이 나타났는지 감지하는 방식의 장단점(`WillDisplayCell`)

  - 나타날 셀이 현재 몇번째 셀인지 쉽게 알 수 있음.
  - 스크롤시, 페이징 처리가 `DidScroll` 에 비해서 훨씬 간단함.

  셀의 높이 값이 고정값이 아닌, 유동적인 값임. 그렇기 때문에 `DidScroll`을 사용하면, 각 셀 높이의 차이로 인해 오차가 발생 가능성이 존재함. 그렇게되면 이벤트가 제때 발생안될 수도 있음. 그래서, 현재 페이징 처리에 부적합하다고 판단이 됨. 그에 비해 `WillDisplayCell`을 사용하면, 셀의 높이와 별개로 나타나는 셀이 몇번째 셀인지가 중요하기 때문에 영향을 안 받게 됨.

  최종적으로 `WillDisplayCell` 을 사용하기로 함.

  페이징 처리를 하기 위해서는 2가지를 준비해야함.

  - 페이징 이벤트를 관리할 `BehaviorRelay`
  - 페이징을 하기 위해 계산할 리스트

  `BehaviorRelay` 가 필요한 이유는, 리소스 낭비 방지를 위해 사용했음.

  페이지 마지막까지 도달할 시, 더 이상의 페이징 처리 요청을 안 보내게 하기 위해서임.

  작동방식

  1. 페이징 이벤트 검증, 페이징 이벤트가 True 이면, 조기 종료 처리
  2. 현재 셀이 전체 셀에서 -2 값과 동일하면서, False 일 때만 동작

  ## 결과(Result) : 해결한 결과 (Image, Gif, 코드 첨부)

  테이블뷰의 마지막 셀로부터 -2 인 셀이 나타나면 페이징 처리하도록 구현이 성공됨.

  - 페이징 처리 전체 코드

  ```swift
  /// 페이징 처리
          tableView.rx.willDisplayCell
              .subscribe(onNext: { [weak self] cell, indexPath in
                  guard let self = self else { return }
                  guard !viewModel.paginationRelay.value else { return } /// True 이면, API 호출하지 않고, 조기 종료
  
                  let sections = dataSource.sectionModels
                  let totalItemsCount = sections.flatMap { $0.items }.count
                  let currentIndex = sections.prefix(indexPath.section).flatMap { $0.items }.count + indexPath.row
  
                  let customQueue = DispatchQueue(label: "validPagination")
  
                  if currentIndex == totalItemsCount - 2, !viewModel.paginationRelay.value {
                      self.indicatorView.startAnimating()
                      self.viewModel.increasePage()
                      if self.searchVC.isActive == true, self.searchVC.searchBar.text?.isEmpty == false {
                          /// 서치바 동작 상태일 때
                          guard let text = self.searchVC.searchBar.text else { return }
  
                          customQueue.async {
                              self.viewModel.requestMoreQueryTodos(query: text) { valid in
  
                                  DispatchQueue.main.async {
                                      if !valid {
                                          self.viewModel.paginationRelay.accept(true)
                                      }
  
                                      self.indicatorView.stopAnimating()
                                  }
                              }
                          }
  
                      } else if self.searchVC.isActive == true, self.searchVC.searchBar.text == "" {
                          customQueue.async {
                              self.viewModel.requestMoreTodos { valid in
  
                                  DispatchQueue.main.async {
                                      if !valid {
                                          self.viewModel.paginationRelay.accept(true)
                                      }
  
                                      self.indicatorView.stopAnimating()
                                  }
                              }
                          }
                      } else {
                          /// 서치바 동작 상태 아닐 때
                          customQueue.async {
                              self.viewModel.requestMoreTodos { valid in
                                  print("#### 클래스명: \\(String(describing: type(of: self))), 함수명: \\(#function), Line: \\(#line), 출력 Log: \\(valid)")
  
                                  DispatchQueue.main.async {
                                      if !valid {
                                          self.pushAlertVC(title: "알림⚠️", detail: "마지막 페이지에 도달했습니다.", image: "book.pages")
                                          self.viewModel.paginationRelay.accept(true)
                                      }
  
                                      self.indicatorView.stopAnimating()
                                  }
                              }
                          }
                      }
                  }
              })
              .disposed(by: viewModel.disposeBag)
      }
  ```

- TableViewCell 삭제시, 다른 셀 애니메이션 동작 현상 처리 고민

  ## 상황(Situation) : 문제 상황 설명

  TableViewCell 삭제 이벤트 발생시, 삭제되는 셀 이외의 다른 셀에도 애니메이션이 동작하는 현상

  ## 목표(Task) : 해결 목표

  삭제되는 셀 이외의 다른 셀은 애니메이션 동작 방지

  ## 행동(Action) : 문제 해결 과정 or 시도

  기존 RxDatasource의 deleteItemCell 을 사용하여 아이템 삭제처리

  삭제 동작은 정상적으로 작동하나, 예상치 못한 애니메이션 동작이 발생함.

  기존 RxDatasource 사용 대신, TableViewDelegate 를 사용하는 방식으로 변경함.

  TableViewDelegate 의 **`tableView(_:trailingSwipeActionsConfigurationForRowAt:)`**  사용

  ```swift
  optional func tableView(
      _ tableView: UITableView,
      trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration?
  ```

  ## 결과(Result) : 해결한 결과 (Image, Gif, 코드 첨부)

  삭제되는 셀 이외의 다른 셀은 애니메이션이 발생하지 않는 것을 확인

  - **`tableView(_:trailingSwipeActionsConfigurationForRowAt:)` 코드**

  ```swift
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
          let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { action, view, perform in
              let currentSection = self.dataSource.sectionModels[indexPath.section]
              let currentItem = currentSection.items[indexPath.row]
              guard let id = currentItem.id else { return }
  
              self.viewModel.removeTodo(data: currentItem, completion: {
                  _ = self.viewModel.dbManager.deleteFavorite(id: id)
  
                  guard let details = currentItem.title else { return }
                  UNUserNotificationCenter.current().addNotificationRequest(title: "할일 삭제됨", details: details)
              })
          }
  
          let configuration = UISwipeActionsConfiguration(actions: [
              deleteAction
          ])
  
          return configuration
      }
  ```
