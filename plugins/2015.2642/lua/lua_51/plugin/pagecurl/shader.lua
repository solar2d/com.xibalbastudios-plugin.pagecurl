LuaQ                5      @@ E  FÀÀ     AÅ@  Ü Á J   ABÂ   Ê  ÉÃ
JB IÂCIBDIÂDIBDIÂÄB EBDÂDBDBÄÊB ÉÂEÉÂDC ÉÉB ÉBÆ"BÉ
  AÂ ¤                      I^         table    concat    math    pi    sort    require    plugin.pagecurl.constants 	   graphics ®  	%%sP_POSITION float R = %.3f;

	#ifdef TINT_SHADOW
		#define TINT_DIST_MAX .6175
		#define TINT_RANGE .275
	#else
		#define TINT_DIST_MAX .5075
		#define TINT_RANGE 1.
	#endif

	P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
	{
		// Reparametrize intervals to [-.5, 1.5], corresponding to the doubled size of
		// the page object. The [0, 1] rect is the page's "regular" area; in the absence
		// of curling, it matches the page exactly.
		//
		// Off-center curling can bring pixels outside of this "canonical" region. The
		// up-front expansion accounts for this; without it, the pixels in question would
		// be ignored and the curled page effectively clipped.
	#ifndef NO_EXPAND
		uv = 2. * uv - .5;
	#endif

		// Find the outward normal, and a vector from a given point along the curling
		// axis to the current pixel. Figure out "how much" of the vector consists of
		// said normal, i.e. where along the normal it gets projected.
		P_POSITION float angle = CoronaVertexUserData.z; // z = angle
		P_POSITION vec2 n = vec2(cos(angle), sin(angle)), to_uv = uv - CoronaVertexUserData.xy; // xy = point on segment
		P_POSITION float npos = dot(n, to_uv);

		// If the vector projects beyond the curling radius, there is no more page left.
		if (npos > R) return vec4(0.);

		// Find the vector's perpendicular component, i.e. how much it runs parallel to
		// the curling axis.
		P_POSITION vec2 perp = vec2(-n.y, +n.x);
		P_POSITION float ppos = dot(perp, to_uv);

		// The front and back parts often overlap. Since curling brings back pixels up
		// top, they will occlude any front pixels. It therefore makes sense to check
		// for them first, avoiding ambiguities down the line.
		//
		// As far as the curl path goes, starting somewhere along the curling axis, a
		// point will trace a semicircle of radius R before leveling out up top. The
		// "horizontal" distance, i.e. along the normal, is R * sin(theta), for theta
		// from 0 (just starting) to pi / 2 (a quarter circle).
		//
		// A circular arc has length of R * theta. Given the distance, 
		// theta, the appropriate texture coordinate distance along the arc can be found.
		// There are two situations to consider in the upper part.
		//
		// If the pixel is "behind" the curling axis, then it must be past the semicircle
		// and on the flat part, and will have covered a distance pi * R + abs(normal component).
		//
		// Otherwise, the pixel is somewhere on the upper half of the semicircle, between
		// angles pi and pi / 2. Since it goes the other way, the "ground" distance is
		// now R * sin(pi / 2 - theta), and the distance covered is (pi / 2 + (pi / 2 -
		// theta)) * R = (pi - theta) * R, for theta from pi / 2 to 0.
		P_POSITION float sin_theta = npos / R, r_theta = npos > 0. ? asin(sin_theta) * R : 0.;
		P_POSITION float scale = 3.14159 * R - (npos > 0. ? r_theta : npos);
		P_UV vec2 top_uv = CoronaVertexUserData.xy + perp * ppos + n * scale; // xy = point on segment

		// If the back of the page reaches this far, return the back pixel.
		P_UV vec2 around = abs(top_uv - .5);
		P_UV float dist = max(around.x, around.y);

		if (dist <= .5)
		{
			P_COLOR vec4 back_color;

		#if defined(NO_FRONT_TEXTURE) || defined(NO_BACK_TEXTURE)
			back_color = vec4(1.);
		#else
			back_color = texture2D(

			#ifdef USE_SECOND_TEXTURE
				CoronaSampler1
			#else
				CoronaSampler0
			#endif

			, top_uv);
		#endif

		#ifndef NO_BACK_COLOR_SCALE
			back_color = CoronaColorScale(back_color);
		#endif

			return back_color;
		}

		// The pixel was not on the back of the page, but still reasonably close: apply some
		// edge effect, such as a border or shadow.
		P_COLOR vec2 tint = vec2(1.);

	#ifndef NO_EDGE_EFFECT
		if (dist <= TINT_DIST_MAX)
		{
			P_COLOR float gray = smoothstep(TINT_DIST_MAX, .5, dist);

			#ifdef TINT_SHADOW
				gray *= smoothstep(.625, .5, min(around.x, around.y));
			#endif

			tint.x = 1. - pow(gray, 3.41) * TINT_RANGE;
		}
	#endif

		// If a front pixel is being curled, figure out its coordinates as described
		// above; otherwise, this is just a flat portion of the page, so the original
		// texture coordinates are correct.
		if (npos > 0.)
		{
			uv = CoronaVertexUserData.xy + perp * ppos + n * r_theta; // xy = point on segment

			// Apply some shadowing along the front curl.
		#ifndef NO_INNER_SHADOWS
			tint.x *= exp(-.271 * sin_theta * sin_theta);
		#endif
		}

		// The final texture coordinate in the front part might not be valid, say within
		// much of the expanded region. Co-opt the tint to clear such pixels.
	#ifndef NO_EXPAND
		around = abs(uv - .5);

		tint *= step(max(around.x, around.y), .5);
	#endif

		// Finally, apply any tint and return the front pixel.
		P_COLOR vec4 color;
		
	#ifdef NO_FRONT_TEXTURE
		color = vec4(1.);
	#else
		color = texture2D(CoronaSampler0, uv);
	#endif

	#if !defined(NO_EDGE_EFFECT) || !defined(NO_EXPAND) || !defined(NO_INNER_SHADOWS)
		color *= tint.xxxy;
	#endif

	#ifndef NO_FRONT_COLOR_SCALE
		color = CoronaColorScale(color);
	#endif

		return color;
	}
    format    Radius    group    xs_pagecurl    vertexData    name    u    default       ð?   min            max    index    v    angle        À       @   GetName        ä   	   9      Ô   ÀÀÄ      Ü@ Ä     A  Ü Ä  ÆÚ@  	Á@ AA@ WÁ@ÀÁ   [A   AA  Ä  @BA  	ÉA ACÄ A  AA @  À   Á Þ                      
       ð?
   effect_%i    format 
   composite 	   no_image 
   generator    filter 	   category 	   fragment    name    defineEffect    %s.xs_pagecurl.%s                             