using ClinicaAPI.DTOs;

namespace ClinicaAPI.Services.Interfaces;

public interface IMedicoService
{
    IEnumerable<MedicoResponseDto> ObtenerTodos();
    MedicoResponseDto ObtenerPorId(int id);
    IEnumerable<MedicoResponseDto> ObtenerPorEspecialidad(string especialidad);
    MedicoResponseDto Crear(MedicoCreateDto dto);
    MedicoResponseDto Actualizar(int id, MedicoUpdateDto dto);
    void Eliminar(int id);
}
