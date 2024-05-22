import * as admin from "firebase-admin";

exports.handler = async (snapshot: any, context: any) => {
    const assinaturaId: string = context.params.assinaturaId;
    const id: string = context.params.id;

    const ref = admin.firestore().collection('assinaturas').doc(assinaturaId);
    const doc = await ref.get();
    const usuarios = doc.get('usuarios');

    if (!usuarios || !(id in usuarios)) {
        ref.update({
            usuarios: admin.firestore.FieldValue.arrayUnion(id)
        })
        .then(function() {
            console.log("Transaction finazada com sucesso!");
        }).catch(function(error) {
            console.log("Transaction falhou: ", error);                
        })
    } 
    
}