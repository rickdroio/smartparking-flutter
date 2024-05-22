import * as admin from "firebase-admin";

exports.handler = async (data: any, res: any) => {
    const assinaturas = admin.firestore().collection('assinaturas');
    const assinaturaRef = await assinaturas.add({
        promo: data['promo'],
        owner: data['uid']
    });
    const assinaturaId = assinaturaRef.id;

    const estacionamentos = admin.firestore().collection('assinaturas').doc(assinaturaId).collection('estacionamentos');
    const estacionamentoRef = await estacionamentos.add({
        endereco: data['enderecoEstacionamento'],
        nome: data['nomeEstacionamento'],
        capacidade: data['capacidadeEstacionamento'],
        ativo: true,
        totalEntradasAberto: 0,
        usuarios: admin.firestore.FieldValue.arrayUnion(data['uid'])
      });
    const estacionamentoId = estacionamentoRef.id;

    const usuarios = admin.firestore().collection('assinaturas').doc(assinaturaId).collection('usuarios').doc(data['uid']);
    await usuarios.set({
        admin: true,
        nome: data['nomeUsuario'],
        email: data['emailUsuario'],
        telefone: data['telefoneUsuario'],
        estacionamento: estacionamentoId
    });

    return {assinaturaId: assinaturaId};
}