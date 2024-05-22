import * as admin from "firebase-admin";

exports.handler = async (data: any, context: any) => {
    const convites = admin.firestore().collection('convites');
    await convites.add({
        ativo: true,
        assinatura: data['assinaturaId'],
        estacionamento: data['estacionamentoId'],
        nome: data['nome'],
        telefone: data['telefone'],
    });
}