//
//  TTSManager.swift
//  OffStageApp
//
//  Created by 신민규 on 10/30/25.
//

import Foundation
import AVFoundation
import Combine // ObservableObject, @Published 등을 사용해 View에 상태 전달

final class TTSManager: NSObject, ObservableObject {

    // MARK: - 공개 상태 (View에서 바인딩)
    @Published var inputText: String = ""              // 사용자가 입력한 텍스트
    @Published var selectedLanguage: String = "ko-KR"  // 언어 고정: 한국어
    // MARK: - 내부 오디오/합성기
    private let synthesizer = AVSpeechSynthesizer()
    /// 합성기 델리게이트와 오디오 세션을 설정한다.
    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    // MARK: - 오디오 세션 설정 (스피커 출력 및 다른 오디오와의 공존 등)
    /// 텍스트 음성 출력이 안정적으로 이뤄지도록 오디오 세션을 구성한다.
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // .playback: 스피커/이어폰 등으로 출력, 백그라운드 재생 옵션도 유리
            // .duckOthers: 다른 앱 소리 볼륨을 살짝 줄여줌(겹칠 때 가독성↑)
            try session.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 합성 유틸리티
    /// 현재 선택된 언어를 적용하고 나머지 파라미터는 시스템 기본값을 사용한 발화를 생성한다.
    private func makeUtterance(from text: String) -> AVSpeechUtterance {
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: selectedLanguage)
        // 필요 시 전/후반 딜레이 등:
        // u.preUtteranceDelay = 0.0
        // u.postUtteranceDelay = 0.0
        return u
    }

    // MARK: - 공개 동작 API (View에서 호출)
    /// 입력 텍스트를 즉시 읽기 시작 (기존 재생 중이던 음성 중단 후 재생)
    func speakNow() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("읽을 텍스트가 없습니다.")
            return
        }
        stop() // 기존 재생 상태 초기화
        let utterance = makeUtterance(from: inputText)
        synthesizer.speak(utterance)
    }

    /// 완전 정지(현재 발화를 즉시 멈춘다)
    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension TTSManager: AVSpeechSynthesizerDelegate {
    /// 합성이 시작되면 콘솔에 진행 상황을 출력한다.
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("TTS 재생 시작: \(utterance.speechString)")
    }

    /// 한 문장의 합성이 완료되면 콘솔로 알린다.
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("TTS 재생 완료.")
    }

    /// 합성 과정에서 오류가 발생하면 콘솔에 메시지를 출력한다.
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didEncounterError error: Error) {
        print("합성 오류: \(error.localizedDescription)")
    }
}
