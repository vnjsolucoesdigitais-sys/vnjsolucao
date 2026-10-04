const token = 'cfut_gBBXVWcW0QqpbhQYgptN3D8I0TAl2CHWQnKredn7d5afd144';
const accountId = 'e1ce5e1ac99b4889839d6651a123b3ff';
const bucketName = 'vnj-painel-arquivos';

async function createBucket() {
  const response = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${accountId}/r2/buckets`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: bucketName,
        jurisdiction: 'ENAM',
      }),
    }
  );

  const result = await response.json();

  if (!response.ok) {
    console.error('Erro ao criar bucket R2:');
    console.error(JSON.stringify(result, null, 2));
    process.exit(1);
  }

  console.log('Bucket criado com sucesso:');
  console.log(JSON.stringify(result, null, 2));
}

createBucket().catch((error) => {
  console.error('Falha inesperada:', error);
  process.exit(1);
});
