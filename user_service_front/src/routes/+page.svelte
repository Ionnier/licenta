<script>
	import { authApiKey } from '../stores/auth';
	import { goto } from '$app/navigation';
	const loginUrl = import.meta.env.VITE_LOGIN_URL || '';
	let error;
	let username = '';
	let password = '';
	let imageUrl = '';
	let useremail = '';
	let completed = false;
	let isLoading = false;

	async function changeData() {
		let data = {};
		if (username.length != 0) {
			data['userName'] = username;
		}
		if (useremail.length != 0) {
			data['userEmail'] = useremail;
		}
		if (imageUrl.length != 0) {
			data['imageUrl'] = imageUrl;
		}
		try {
			isLoading = true;
			const result = await fetch(`${loginUrl}/api/updateSelf`, {
				method: 'PATCH',
				body: JSON.stringify(data),
				headers: new Headers({
					Authorization: `Bearer ${$authApiKey}`,
					'Content-Type': 'application/json'
				})
			});
			if (result.status == 200) {
				completed = true;
				setTimeout(() => {
					completed = false;
				}, 3000);
				isLoading = false;
			} else {
				const json = await result.json();
				error = json.message;
				console.log(json);
				isLoading = false;
			}
		} catch (e) {
			console.log(e);
			error = 'Error!';
			isLoading = false;
		}
	}
</script>

<h1>Welcome to the User service</h1>

{#if $authApiKey == null}
	<p>
		You can login <a href="/login"> here</a>.
	</p>
{:else}
	{#await fetch(`${loginUrl}/api/self`, { headers: { Authorization: `Bearer ${$authApiKey}` } })}
		Loading...
	{:then data}
		{#await data.json()}
			Loading
		{:then user}
			<div class="form-group">
				<label>
					Email
					<input
						class="form-control {error == null ? '' : 'is-invalid'}"
						placeholder={user.data.userEmail}
						bind:value={useremail}
						required
					/>
				</label>

				<label>
					Username
					<input
						class="form-control {error == null ? '' : 'is-invalid'}"
						placeholder={user.data.userName}
						bind:value={username}
						required
					/>
				</label>

				<label>
					Image Url
					<input
						class="form-control {error == null ? '' : 'is-invalid'}"
						placeholder={user.data.imageUrl}
						bind:value={imageUrl}
						required
					/>
				</label>
				{#if user.data.imageUrl != null && user.data.imageUrl.length != 0}
					<img src={user.data.imageUrl} alt="Current" width="128px" />
				{/if}
				<p />

				{#if error != null}
					<div class="alert alert-danger" role="alert">
						{error}
					</div>
				{/if}

				<button on:click|preventDefault={changeData} class="btn btn-primary">Change data</button>
				{#if completed}
					<div class="alert alert-success" role="alert">Updated!</div>
				{/if}
			</div>
		{/await}
	{:catch error}
		Error
	{/await}
{/if}

{#if isLoading}
	<div class="progress">
		<div
			class="progress-bar progress-bar-striped progress-bar-animated"
			role="progressbar"
			aria-valuenow="100"
			aria-valuemin="0"
			aria-valuemax="100"
		/>
	</div>
{/if}
