import startSeedingProcess from '@salesforce/apex/DataSeedingController.startSeedingProcess';

export async function initiateSeedingProcess(seedingDetails, csvDataResponse) {
  return new Promise((resolve) => {
    startSeedingProcess({ seedingDetails: seedingDetails, csvDataResponse: csvDataResponse })
      .then((results) => {
        if (results && results.isSuccess) {
          resolve({
            results: results,
            errors: null,
          });
        } else {
          const errors = results.body ? results : { message: results.message };
          resolve({
            results: null,
            errors,
          });
        }
      })
      .catch((error) => {
        resolve({
          results: null,
          errors: { body: { message: error.body.message } },
        });
      });
  });
}