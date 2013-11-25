var sphereVertexPositionBuffer;
var sphereVertexNormalBuffer;
var sphereVertexTextureCoordBuffer;
var sphereVertexIndexBuffer;

function initSphere() {
	var latitudeBands = 30;
	var longitudeBands = 30;
	var radius = 2;

	var vertexPositionData = [];
	var normalData = [];
	var textureCoordData = [];
	for (var latNumber=0; latNumber <= latitudeBands; latNumber++) {
		var theta = latNumber * Math.PI / latitudeBands;
		var sinTheta = Math.sin(theta);
		var cosTheta = Math.cos(theta);

		for (var longNumber=0; longNumber <= longitudeBands; longNumber++) {
			var phi = longNumber * 2 * Math.PI / longitudeBands;
			var sinPhi = Math.sin(phi);
			var cosPhi = Math.cos(phi);

			var x = cosPhi * sinTheta;
			var y = cosTheta;
			var z = sinPhi * sinTheta;
			var u = 1 - (longNumber / longitudeBands);
			var v = 1 - (latNumber / latitudeBands);

			normalData.push(x);
			normalData.push(y);
			normalData.push(z);
			textureCoordData.push(u);
			textureCoordData.push(v);
			vertexPositionData.push(radius * x);
			vertexPositionData.push(radius * y);
			vertexPositionData.push(radius * z);
		}
	}

	var indexData = [];
	for (var latNumber=0; latNumber < latitudeBands; latNumber++) {
		for (var longNumber=0; longNumber < longitudeBands; longNumber++) {
			var first = (latNumber * (longitudeBands + 1)) + longNumber;
			var second = first + longitudeBands + 1;
			indexData.push(first);
			indexData.push(second);
			indexData.push(first + 1);

			indexData.push(second);
			indexData.push(second + 1);
			indexData.push(first + 1);
		}
	}

	sphereVertexNormalBuffer = gl.createBuffer();
	gl.bindBuffer(gl.ARRAY_BUFFER, sphereVertexNormalBuffer);
	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(normalData), gl.STATIC_DRAW);
	sphereVertexNormalBuffer.itemSize = 3;
	sphereVertexNormalBuffer.numItems = normalData.length / 3;

	sphereVertexTextureCoordBuffer = gl.createBuffer();
	gl.bindBuffer(gl.ARRAY_BUFFER, sphereVertexTextureCoordBuffer);
	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(textureCoordData), gl.STATIC_DRAW);
	sphereVertexTextureCoordBuffer.itemSize = 2;
	sphereVertexTextureCoordBuffer.numItems = textureCoordData.length / 2;

	sphereVertexPositionBuffer = gl.createBuffer();
	gl.bindBuffer(gl.ARRAY_BUFFER, sphereVertexPositionBuffer);
	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertexPositionData), gl.STATIC_DRAW);
	sphereVertexPositionBuffer.itemSize = 3;
	sphereVertexPositionBuffer.numItems = vertexPositionData.length / 3;

	sphereVertexIndexBuffer = gl.createBuffer();
	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sphereVertexIndexBuffer);
	gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indexData), gl.STATIC_DRAW);
	sphereVertexIndexBuffer.itemSize = 1;
	sphereVertexIndexBuffer.numItems = indexData.length;
}

function drawSphere() {
	try {
		var s = shaders[currentShader].program;

		if (s.vertexPositionAttribute >= 0) {
			gl.bindBuffer(gl.ARRAY_BUFFER, sphereVertexPositionBuffer);
			gl.vertexAttribPointer(s.vertexPositionAttribute, sphereVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
		}

		if (s.textureCoordAttribute >= 0) {
			gl.bindBuffer(gl.ARRAY_BUFFER, sphereVertexTextureCoordBuffer);
			gl.vertexAttribPointer(s.textureCoordAttribute, sphereVertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0);
		}

		if (s.vertexNormalAttribute >= 0) {
			gl.bindBuffer(gl.ARRAY_BUFFER, sphereVertexNormalBuffer);
			gl.vertexAttribPointer(s.vertexNormalAttribute, sphereVertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0);
		}

		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sphereVertexIndexBuffer);
		gl.drawElements(gl.TRIANGLES, sphereVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);
	} catch(e) {}
}

