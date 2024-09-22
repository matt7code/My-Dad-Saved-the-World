extends MeshInstance3D

var rings = 50
var radial_segments = 50
var height = 1
var radius = 1

# Set up the PoolVectorXArrays.
var verts = PackedVector3Array()
var uvs = PackedVector2Array()
var normals = PackedVector3Array()
var indices = PackedInt32Array()

func _ready() -> void:
	# This will be the array that we keep our surface information in, it will
	# hold all the arrays of data that the surface needs. Godot will expect it
	# to be of size Mesh.ARRAY_MAX, so resize it accordingly.
	var arr = []

	arr.resize(Mesh.ARRAY_MAX)

	# Next create the arrays for each data type you will use.


	#######################################
	## Insert code here to generate mesh ##
	#######################################

	generate_sphere()


	# Once you have filled your data arrays with your geometry you can create a
	# mesh by adding each array to surface_array and then committing to the mesh.
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_INDEX] = indices

	# No blendshapes or compression used.

#	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)


func generate_sphere():
	### Generating geometry ###
	# Here is sample code for generating a sphere. Although the code is
	# presented in GDScript, there is nothing Godot specific about the approach
	# to generating it. This implementation has nothing in particular to do with
	# ArrayMeshes and is just a generic approach to generating a sphere. If you
	# are having trouble understanding it or want to learn more about procedural
	# geometry in general, you can use any tutorial that you find online.

	# Vertex indices.
	var thisrow = 0
	var prevrow = 0
	var point = 0

	# Loop over rings.
	for i in range(rings + 1):
		var v = float(i) / rings
		var w = sin(PI * v)
		var y = cos(PI * v)

		# Loop over segments in ring.
		for j in range(radial_segments):
			var u = float(j) / radial_segments
			var x = sin(u * PI * 2.0)
			var z = cos(u * PI * 2.0)
			var vert = Vector3(x * radius * w, y, z * radius * w)
			verts.append(vert)
			normals.append(vert.normalized())
			uvs.append(Vector2(u, v))
			point += 1

			# Create triangles in ring using indices.
			if i > 0 and j > 0:
				indices.append(prevrow + j - 1)
				indices.append(prevrow + j)
				indices.append(thisrow + j - 1)

				indices.append(prevrow + j)
				indices.append(thisrow + j)
				indices.append(thisrow + j - 1)

		if i > 0:
			indices.append(prevrow + radial_segments - 1)
			indices.append(prevrow)
			indices.append(thisrow + radial_segments - 1)

			indices.append(prevrow)
			indices.append(prevrow + radial_segments)
			indices.append(thisrow + radial_segments - 1)

		prevrow = thisrow
		thisrow = point

  # Commit to the ArrayMesh.
