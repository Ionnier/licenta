<script lang="ts">
	import { goto } from '$app/navigation';
	import { authApiKey } from '../../stores/auth';
	import { page } from '$app/stores';

	let error: String | any = null;
	let username: String = '';
	let password: String = '';

	async function signup() {
		if (username.length == 0 || password.length == 0) {
			console.log(username, password);
			error = 'Empty';
			return false;
		}
		const loginUrl = import.meta.env.VITE_LOGIN_URL;
		const returnUrl = $page.url.searchParams.has('return_url');
		const data = {
			userEmail: username,
			userPassword: password
		};
		try {
			const result = await fetch(`${loginUrl}/api/signup`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify(data)
			});
			const json = await result.json();
			if (result.status != 200) {
				error = json.message;
				return false;
			}
			goto('/login');
			return;
		} catch (e) {
			error = 'Error';
			return false;
		}
	}
</script>

<div class=".container-fluid" style="vh-100">
	<div class="row align-items-center">
		<div class="col-sm" />
		<div class="col-sm h-100 d-inline-block">
			<h2>Signup</h2>
			<div class="form-group">
				<label for="exampleInputEmail1">Email address</label>
				<input
					type="email"
					class="form-control {error == null ? '' : 'is-invalid'}"
					id="exampleInputEmail1"
					aria-describedby="emailHelp"
					placeholder="Enter email"
					bind:value={username}
					required
				/>
			</div>
			<div class="form-group">
				<label for="exampleInputPassword1">Password</label>
				<input
					type="password"
					class="form-control {error == null ? '' : 'is-invalid'}"
					id="exampleInputPassword1"
					placeholder="Password"
					bind:value={password}
					required
				/>
			</div>
			{#if error != null}
				<div class="alert alert-danger" role="alert">
					{error}
				</div>
			{/if}
			<button on:click|preventDefault={signup} class="btn btn-primary">Sign Up</button>
		</div>
		<div class="col-sm" />
	</div>
</div>
