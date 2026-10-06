const http = require('http');
const client = require('prom-client');
const { DefaultAzureCredential } = require("@azure/identity");
const { BlobServiceClient } = require("@azure/storage-blob");

// Configuración segura de Azure (sin contraseñas ni access keys)
const accountName = "stshoesprod01";
const containerName = "images-shoes";
const blobName = "shoes_munich.jpg"; // <-- archivo subido en contenedor azure

const credential = new DefaultAzureCredential();
const blobServiceClient = new BlobServiceClient(
  `https://${accountName}.blob.core.windows.net`,
  credential
);

const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ register: client.register });

const server = http.createServer(async (req, res) => {
    if (req.url === '/metrics') {
        res.setHeader('Content-Type', client.register.contentType);
        res.end(await client.register.metrics());
    } 
    else if (req.url === '/') {
        try {
            // Conectar al contenedor y buscar la imagen
            const containerClient = blobServiceClient.getContainerClient(containerName);
            const blobClient = containerClient.getBlobClient(blobName);

            // Descargar el contenido
            const downloadBlockBlobResponse = await blobClient.download(0);
            
            // Servir la imagen directamente al navegador
            res.setHeader('Content-Type', 'image/jpeg'); 
            downloadBlockBlobResponse.readableStreamBody.pipe(res);
        } catch (error) {
            console.error("Error conectando con Azure:", error.message);
            res.statusCode = 500;
            res.end(`Error de Azure: ${error.message}\n`);
        }
    } 
    else {
        res.statusCode = 404;
        res.end('Ruta no encontrada\n');
    }
});

server.listen(3000, () => {
  console.log('Servidor de shoes corriendo en el puerto 3000');
});

