import * as admin from "firebase-admin";

exports.handler = async (change: any, context: any) => {
    let incremento = 0;
    const dataAfter = change.after.data();
    const dataBefore = change.before.data();

    if (!change.before.exists) {
        // New document Created : add one to count
        if (dataAfter.ativo) incremento = 1;
    } 
    else if (change.before.exists && dataBefore.ativo != dataAfter.ativo) {
        // edit document && edited
        if (dataAfter.ativo) incremento = 1;
        else incremento = -1;
    }

    if (incremento !== 0) {
        const ref = admin.firestore().collection('assinaturas').doc(context.params.assinaturaId);
        ref.update({estacionamentosAtivos: admin.firestore.FieldValue.increment(incremento)})
        .then(function() {
            console.log("Transaction finalizada com sucesso!");           
        }).catch(function(error) {
            console.log("Transaction falhou: ", error);
        });         
    }  
}