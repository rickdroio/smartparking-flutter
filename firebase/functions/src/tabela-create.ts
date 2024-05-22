import * as admin from "firebase-admin";

exports.handler = async (snapshot: any, context: any) => {
    const dataHora = admin.firestore.FieldValue.serverTimestamp();

    const camposUpdate = {
        createdTabela: dataHora,
        updatedTabela: dataHora,
    }
    
    return snapshot.ref.update(camposUpdate);
}