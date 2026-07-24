//
//  AuthMapper.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Maps the `AuthDTO` wire model into the domain `AuthResult`.
enum AuthMapper {
    static func map(_ dto: AuthDTO) -> AuthResult {
        AuthResult(user: UserMapper.map(dto.user), token: dto.token)
    }
}
