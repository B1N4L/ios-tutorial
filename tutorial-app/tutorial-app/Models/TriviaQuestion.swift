////
////  Quiz.swift
////  tutorial-app
////
////  Created by Student 2 on 2026-07-02.
////
//
//import Foundation
//
//struct Quiz: Decodable, Identifiable {
//    let id = UUID()
//
//    let category: String
//    let type: String
//    let difficulty: String
//    let question: String
//    let correct_answer: String
//    let incorrect_answers: [String]
//
//    enum CodingKeys: String, CodingKey {
//        case category
//        case type
//        case difficulty
//        case question
//        case correct_answer
//        case incorrect_answers
//    }
//}
import Foundation

struct QuizResponse: Decodable {
    let response_code: Int
    let results: [Quiz]
}

struct Quiz: Decodable, Identifiable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]

    enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correct_answer
        case incorrect_answers
    }
}
