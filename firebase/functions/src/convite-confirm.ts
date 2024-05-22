import * as admin from "firebase-admin";

exports.handler = async (change: any, context: any) => {
    const data = change.after.data();
    //console.log('data', data);
    
    if (data.uid && data.ativo) { //usuario confirmou convite
        const uid = data.uid;
        const assinatura = data.assinatura;
       
        //adicionar convitecomo como usuario do sistema
        const ref = admin.firestore().collection('assinaturas').doc(assinatura).collection('usuarios').doc(uid);
        ref.create({
            admin: false,
            email: '',
            nome: data.nome,
            telefone: data.telefone,
            estacionamento: data.estacionamento
        })
        .then(function() {
            console.log("Transaction finalizada com sucesso!");           
        }).catch(function(error) {
            console.log("Transaction falhou: ", error);
        });

        //adicionar usuario como membro do estacionamento
        const refEstacionamento = admin.firestore().collection('assinaturas').doc(assinatura).collection('estacionamentos').doc(data.estacionamento);
        refEstacionamento.update({
            usuarios: admin.firestore.FieldValue.arrayUnion(uid)
        })
        .then(function() {
            console.log("Transaction finalizada com sucesso!");           
        }).catch(function(error) {
            console.log("Transaction falhou: ", error);
        });        

        //desativar convite
        admin.firestore().collection('convites').doc(context.params.id).update({
            ativo: false
        })
        .then(function() {
            console.log("Transaction finalizada com sucesso!");           
        }).catch(function(error) {
            console.log("Transaction falhou: ", error);
        });        
    }    
}