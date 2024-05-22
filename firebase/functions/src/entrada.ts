import * as admin from "firebase-admin";

exports.handler = async (snapshot: any, context: any) => {
    const dataHora = admin.firestore.FieldValue.serverTimestamp();

    try {
        //criar registro publico do ticket
        //const publicRef = await admin.firestore().collection('public').doc();
        //await publicRef.set({dataEntrada: dataHora,});

        const camposUpdate = {
            dataServer: dataHora,
            //finalizadoEntrada: false,
            //pinEntrada: securePin.generatePinSync(4),
            //idPublic: publicRef.id,
            codEntrada: 0
        }    
        
        const clientId = context.params.clientId;
        //console.log('clientID', clientId);

        // transaction CODENTRADA GENERATOR
        const generatorRef = admin.firestore().collection('clients/'+clientId+'/generators').doc('generators');
        await admin.firestore().runTransaction( function(transaction) {

            return transaction.get(generatorRef).then(function(sfDoc) {
                if (!sfDoc.exists) {
                    //throw "Document does not exist!";
                }

                if (sfDoc.data() === null) {
                    camposUpdate.codEntrada = 1;
                    transaction.set(generatorRef, {entrada: 1});

                } else {
                    const newCodEntrada = sfDoc.data()!.entrada + 1;
                    camposUpdate.codEntrada = newCodEntrada;
                    transaction.update(generatorRef, {entrada: newCodEntrada});
                }
                
            });    

        }).then(function() {
            console.log("Transaction finazada com sucesso!");
        }).catch(function(error) {
            console.log("Transaction falhou: ", error);                
        })        

        return snapshot.ref.update(camposUpdate);   
    }
    catch(error) {
        console.log(error);
        //response.status(500).send(error);        
    }
};