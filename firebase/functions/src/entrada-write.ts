import * as admin from "firebase-admin";
//https://firebase.googleblog.com/2019/03/increment-server-side-cloud-firestore.html

exports.handler = async (change: any, context: any) => {
    let incremento = 0;
    
    if (!change.before.exists) {
        // New document Created : add one to count
        incremento = 1;        
    } 
    else if (change.before.exists && change.after.exists) {
        // entrada finalizada
        const data = change.after.data();
        if (data.entradaFinalizada) incremento=-1;
    }

    if (incremento !== 0) {
        const ref = admin.firestore().collection('assinaturas').doc(context.params.assinaturaId).collection('estacionamentos').doc(context.params.estacionamentoId);
        ref.update({totalEntradasAberto: admin.firestore.FieldValue.increment(incremento)})
        .then(function() {
            console.log("Transaction finalizada com sucesso!");           
        }).catch(function(error) {
            console.log("Transaction falhou: ", error);
        });         
    }
  
}