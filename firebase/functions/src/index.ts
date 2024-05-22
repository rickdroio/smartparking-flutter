import * as functions from 'firebase-functions';
import * as admin from "firebase-admin";

const assinaturaCreate = require('./assinatura-create');
const usuarioCreate = require('./usuario-create');
const conviteConfirm = require('./convite-confirm');
const assinaturaNew = require('./assinatura-new');
const conviteNew = require('./convite-new');
const entradaWrite = require('./entrada-write');
const estacionamentoWrite = require('./estacionamento-write');


admin.initializeApp(functions.config().firebase);

//exports.entradaCreate = functions.firestore.document("/clients/{clientId}/entradas/{entradaId}").onCreate(entradaModule.handler); >> precisa atualizar
//exports.tabelaCreate = functions.firestore.document("/clients/{clientId}/tabelas_preco/{tabelaId}").onCreate(tabelaCreate.handler);
//exports.tabelaUpdate = functions.firestore.document("/clients/{clientId}/tabelas_preco/{tabelaId}").onUpdate(tabelaUpdate.handler);
exports.assinaturaCreate = functions.firestore.document("/assinaturas/{id}").onCreate(assinaturaCreate.handler);

//manter lista usuarios na root assinaturas para matching de login
exports.usuarioCreate = functions.firestore.document("/assinaturas/{assinaturaId}/usuarios/{id}").onCreate(usuarioCreate.handler);

//manter lista usuarios na root assinaturas para matching de login
exports.conviteConfirm = functions.firestore.document("/convites/{id}").onUpdate(conviteConfirm.handler);

//manter registro de quantidade total de entrada
exports.entradaWrite = functions.firestore.document("/assinaturas/{assinaturaId}/estacionamentos/{estacionamentoId}/entradas/{entradaId}").onWrite(entradaWrite.handler);

//registro de qtde de estacionamentos ativos (para controle de assinatura)
exports.estacionamentoWrite = functions.firestore.document("/assinaturas/{assinaturaId}/estacionamentos/{estacionamentoId}").onWrite(estacionamentoWrite.handler);

exports.assinaturaNew = functions.https.onCall(assinaturaNew.handler);
exports.conviteNew = functions.https.onCall(conviteNew.handler);

