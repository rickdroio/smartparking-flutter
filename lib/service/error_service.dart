class ErrorService {

  static String translate(dynamic error) {
    if (error.code != null) {
      switch (error.code) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          return 'Email já cadastrado';
          break;

        case 'ERROR_NETWORK_REQUEST_FAILED':
          return 'Sem conexão';
          break;

        case 'ERROR_WEAK_PASSWORD':
          return 'Senha muito fraca!';
          break;

        case 'ERROR_SESSION_EXPIRED':
          return 'Tempo limite de autenticação esgotado. Tente novamente.';
          break;

        case 'ERROR_INVALID_VERIFICATION_CODE':
          return 'Código verificação inválido';
          break;

        default:
          return error.code;
      }
    }
    else {
      return error.toString();
    }
  }

}