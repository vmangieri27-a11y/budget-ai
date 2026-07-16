String autoCategorize(
String description,
bool expense
){

final d=description.toLowerCase();



if(!expense){

if(
d.contains('stipendio') ||
d.contains('salary') ||
d.contains('bonifico')
){
return 'Stipendio';
}

return 'Altra Entrata';

}



if(
d.contains('farmacia') ||
d.contains('medico') ||
d.contains('dentista')
){
return 'Salute';
}



if(
d.contains('palestra') ||
d.contains('sport')
){
return 'Attività Fisica';
}



if(
d.contains('amazon') ||
d.contains('zara')
){
return 'Shopping';
}



if(
d.contains('ristorante') ||
d.contains('bar') ||
d.contains('pizza')
){
return 'Ristoranti e Bar';
}



if(
d.contains('benzina') ||
d.contains('trenitalia')
){
return 'Trasporti';
}



if(
d.contains('netflix') ||
d.contains('spotify')
){
return 'Abbonamenti';
}



if(
d.contains('hotel') ||
d.contains('volo')
){
return 'Viaggi';
}



if(
d.contains('veterinario') ||
d.contains('pet')
){
return 'Animali';
}



if(
d.contains('affitto') ||
d.contains('condominio') ||
d.contains('bolletta') ||
d.contains('luce') ||
d.contains('gas')
){
return 'Gestione Casa';
}



return 'Altro';

}