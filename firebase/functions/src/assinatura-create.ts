import * as admin from "firebase-admin";

exports.handler = async (snapshot: any, context: any) => {
    let trialDays = 15; //15 dias de trial padrão
    const dataHora = admin.firestore.FieldValue.serverTimestamp();
    const trialPeriod = admin.firestore.Timestamp.now().toDate();   

    const original = snapshot.data();
    console.log('original', original);
    const promo = original.promo;

    //pegar dias de trial do promo
    //+ incrementar o qtde de uso
    if (promo) {
        const promoRef = admin.firestore().collection('promo').doc(promo);
        await admin.firestore().runTransaction( function(transaction) {

            return transaction.get(promoRef).then(function(doc) {
                if (doc.exists && doc.data() !== null) {
                    //verifica se nao expiou ou se utilizou mais do que permitido
                    if (doc.data()!.expireDate <= dataHora && doc.data()!.used<doc.data()!.qty) {
                        const used = doc.data()!.used + 1;
                        trialDays = doc.data()!.trialDays;
                        transaction.update(promoRef, {used: used}); //atualiza utilizavao do promo   
                    }
                }

                trialPeriod.setDate(trialPeriod.getDate() + trialDays);                
                const camposUpdate = {
                    dataRegistro: dataHora,
                    dataFimAssinatura: trialPeriod,
                    assinaturaDiasTrial: trialDays
                }
                //console.log('result1', camposUpdate);
                return snapshot.ref.update(camposUpdate);    
            });

        });
    }
    else { //sem promo      
        trialPeriod.setDate(trialPeriod.getDate() + trialDays);
        const camposUpdate = {
            dataRegistro: dataHora,
            dataFimAssinatura: trialPeriod,
            assinaturaDiasTrial: trialDays
        }        
        //console.log('result1', camposUpdate);
        return snapshot.ref.update(camposUpdate);
    }
}


