var sinesp = require('sinesp-api');

// My function
const myfunction = async function() {
    let vehicle = await sinesp.search('EJK2706');
    return vehicle;
}
  
// Start function
const start = async function() {
    const result = await myfunction();
    console.log(result);
}
  
  // Call start
  start();

